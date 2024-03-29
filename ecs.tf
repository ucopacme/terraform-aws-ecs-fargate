data "aws_caller_identity" "current" {}

data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "assume_by_ecs" {
  statement {
    sid     = "AllowAssumeByEcsTasks"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_by_ecs_with_source_account" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        "${data.aws_caller_identity.current.account_id}"
      ]
    }
  }
}

data "aws_iam_policy_document" "task_get_tagged_secret_values" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "secretsmanager:ResourceTag/${var.task_secret_tag_key}"

      values = [
        "${var.task_secret_tag_value}"
      ]
    }
  }
}

data "aws_iam_policy_document" "task_get_all_secret_values" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "task_get_secret_values" {
  name        = join("-", [var.name, "ecs", "task", "GetSecretValues"])
  description = "Allow secrets retrieval for ${var.name} ECS tasks"
  policy      = var.task_secret_tag_value == "" ? data.aws_iam_policy_document.task_get_all_secret_values.json : data.aws_iam_policy_document.task_get_tagged_secret_values.json
}

resource "aws_iam_role" "execution_role" {
  name               = "${var.name}_ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
}

resource "aws_iam_role_policy_attachment" "execution_role_managed_policy_attachment" {
  role       = aws_iam_role.execution_role.name
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}

resource "aws_iam_role_policy" "execution_role" {
  count  = var.task_execution_role_inline_policy != "" ? 1 : 0
  role   = aws_iam_role.execution_role.name
  policy = var.task_execution_role_inline_policy
}

resource "aws_iam_role_policy_attachment" "execution_role_get_secret_values" {
  role       = aws_iam_role.execution_role.name
  policy_arn = aws_iam_policy.task_get_secret_values.arn
}

resource "aws_iam_role" "task_role" {
  name               = "${var.name}_ecsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ecs_with_source_account.json
}

resource "aws_iam_role_policy" "task_role_policy" {
  count  = var.task_role_inline_policy != "" ? 1 : 0
  role   = aws_iam_role.task_role.name
  policy = var.task_role_inline_policy
}

resource "aws_iam_role_policy_attachment" "task_role_get_secret_values" {
  role       = aws_iam_role.task_role.name
  policy_arn = aws_iam_policy.task_get_secret_values.arn
}

resource "aws_ecs_cluster" "this" {
  count = var.enable_ecs_cluster ? 1 : 0
  name  = join("-", [var.name, "cluster"])
  tags  = var.tags
  configuration {
    execute_command_configuration {
      #kms_key_id = aws_kms_key.example.arn
      logging = var.enable_execute_command ? "OVERRIDE" : "NONE"

      dynamic "log_configuration" {
        for_each = var.enable_execute_command ? [1] : []
        content {
          cloud_watch_encryption_enabled = false
          cloud_watch_log_group_name     = aws_cloudwatch_log_group.exec[0].name
        }
      }
    }
  }

  setting {
    name  = "containerInsights"
    value = var.containerInsights ? "enabled" : "disabled"
  }
}


resource "aws_cloudwatch_log_group" "this" {
  name              = var.task_log_group_name != "" ? var.task_log_group_name : join("-", [var.name, "ecs-task-lg"])
  retention_in_days = var.retention_in_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "exec" {
  count             = var.enable_execute_command ? 1 : 0
  name              = var.exec_log_group_name != "" ? var.exec_log_group_name : join("-", [var.name, "ecs-exec-lg"])
  retention_in_days = var.retention_in_days
  tags              = var.tags
}

resource "aws_iam_role_policy" "ecs_exec_policy" {
  count = var.enable_execute_command ? 1 : 0
  name  = "EcsExecPolicy"
  role  = aws_iam_role.task_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "logs:DescribeLogGroups",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.exec[0].name}:*"
      },
    ]
  })
}

locals {
  task_log_multiline_pattern = var.task_log_multiline_pattern != "" ? { "awslogs-multiline-pattern" = var.task_log_multiline_pattern } : null
  #task_container_secrets       = length(var.task_container_secrets) > 0 ? { "secrets" = var.task_container_secrets } : null
  #repository_credentials       = length(var.repository_credentials) > 0 ? { "repositoryCredentials" = { "credentialsParameter" = var.repository_credentials } } : null
  task_container_port_mappings = var.task_container_port == 0 ? var.task_container_port_mappings : concat(var.task_container_port_mappings, [{ containerPort = var.task_container_port, hostPort = var.task_container_port, protocol = "tcp" }])
  # task_container_environment   = [for k, v in var.task_container_environment : { name = k, value = v }]
  task_container_mount_points = concat([for v in var.efs_volumes : { containerPath = v.mount_point, readOnly = v.readOnly, sourceVolume = v.name }], var.mount_points)

  log_configuration_options = merge({
    "awslogs-group"         = aws_cloudwatch_log_group.this.name
    "awslogs-region"        = "us-west-2"
    "awslogs-stream-prefix" = var.awslogs_stream_prefix
  }, local.task_log_multiline_pattern)

  container_definition = merge({
    "name"                   = var.name
    "image"                  = var.image
    "essential"              = true
    "cpu"                    = var.container_cpu
    "memory"                 = var.container_memory
    "portMappings"           = local.task_container_port_mappings
    "stopTimeout"            = var.stop_timeout
    "command"                = var.task_container_command
    "environment"            = var.environment
    "secrets"                = var.secrets
    "systemControls"         = var.systemControls
    "MountPoints"            = local.task_container_mount_points
    "linuxParameters"        = var.linux_parameters
    "readonlyRootFilesystem" = var.readonlyRootFilesystem
    "logConfiguration" = {
      "logDriver" = "awslogs"
      "options"   = local.log_configuration_options
    }
    "privileged" : var.privileged
  }, )
}

resource "aws_ecs_task_definition" "this" {
  family                   = join("-", [var.name, "task"]) # Naming our first task
  tags                     = var.tags
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.memory  # Specifying the memory our container requires
  cpu                      = var.cpu     # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  dynamic "volume" {
    for_each = var.efs_volumes
    content {
      name = volume.value["name"]
      efs_volume_configuration {
        file_system_id     = volume.value["file_system_id"]
        root_directory     = volume.value["root_directory"]
        transit_encryption = "ENABLED"
        authorization_config {
          access_point_id = volume.value["access_point_id"]
          iam             = "ENABLED"
        }
      }
    }
  }
  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value["name"]
    }
  }
  container_definitions = jsonencode(concat([local.container_definition], var.sidecar_containers))
}


### ECS Services

data "aws_ecs_task_definition" "this" {
  task_definition = aws_ecs_task_definition.this.family
  depends_on      = [aws_ecs_task_definition.this]
}
resource "aws_ecs_service" "this" {
  name                   = join("-", [var.name, "service"])
  task_definition        = "${aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, data.aws_ecs_task_definition.this.revision)}"
  cluster                = var.cluster_arn
  enable_execute_command = var.enable_execute_command
  tags                   = var.tags
  propagate_tags         = "TASK_DEFINITION"
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name != "" ? var.container_name : var.name
    container_port   = var.container_port
  }

  launch_type                        = "FARGATE"
  desired_count                      = var.desired_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  deployment_controller {
    type = "CODE_DEPLOY"
  }
  ### Deployment circuit breaker is not support with code_deploy controller

  #deployment_circuit_breaker{
  # enable=true
  #rollback=true
  #}

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = var.assign_public_ip
    security_groups  = var.security_groups
  }
  lifecycle {
    ignore_changes = [desired_count, task_definition, load_balancer, network_configuration]
    # create_before_destroy = true
  }


  #depends_on = [var.http_tcp_listener_arns]
}


## new autoscaling

module "ecs-autoscaling" {
  count = var.enable_autoscaling ? 1 : 0

  source = "git::https://git@github.com/ucopacme/terraform-aws-ecs-fargate-auto-scaling"
  #version = "1.0.6"

  name                      = var.name
  ecs_cluster_name          = var.cluster_name
  ecs_service_name          = aws_ecs_service.this.name
  max_cpu_threshold         = var.max_cpu_threshold
  min_cpu_threshold         = var.min_cpu_threshold
  max_cpu_evaluation_period = var.max_cpu_evaluation_period
  min_cpu_evaluation_period = var.min_cpu_evaluation_period
  max_cpu_period            = var.max_cpu_period
  min_cpu_period            = var.min_cpu_period
  scale_target_max_capacity = var.scale_target_max_capacity
  scale_target_min_capacity = var.scale_target_min_capacity
  tags                      = var.tags
}
