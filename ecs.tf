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

data "aws_iam_policy_document" "execution_role" {
  statement {
    sid    = "AllowECRLogging"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ecs:DescribeClusters",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:List*",
      "secretsmanager:GetResourcePolicy"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "execution_role" {
  name               = "${var.name}_ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
}

resource "aws_iam_role_policy" "execution_role" {
  role   = aws_iam_role.execution_role.name
  policy = data.aws_iam_policy_document.execution_role.json
}



resource "aws_ecs_cluster" "this" {
  count = var.enable_ecs_cluster ? 1 : 0
  name = join("-", [var.name, "cluster"])
  tags = var.tags
  configuration {
  execute_command_configuration {
      #kms_key_id = aws_kms_key.example.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = var.log_group_name != "" ? var.log_group_name : aws_cloudwatch_log_group.exec.name
      }
    }
  }
  dynamic "setting" {
    for_each = var.containerInsights == true ? [1] : []
    content {
      name  = "containerInsights"
      value = "enabled"
    }
  }
}



resource "aws_cloudwatch_log_group" "this" {
  name              = join("-", [var.name, "ecs-task-lg"])
  retention_in_days = var.retention_in_days
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "exec" {
  name              = join("-", [var.name, "ecs-exec-lg"])
  retention_in_days = var.retention_in_days
  tags = var.tags
}


locals {
  log_multiline_pattern        = var.log_multiline_pattern != "" ? { "awslogs-multiline-pattern" = var.log_multiline_pattern } : null
  #task_container_secrets       = length(var.task_container_secrets) > 0 ? { "secrets" = var.task_container_secrets } : null
  #repository_credentials       = length(var.repository_credentials) > 0 ? { "repositoryCredentials" = { "credentialsParameter" = var.repository_credentials } } : null
  task_container_port_mappings = var.task_container_port == 0 ? var.task_container_port_mappings : concat(var.task_container_port_mappings, [{ containerPort = var.task_container_port, hostPort = var.task_container_port, protocol = "tcp" }])
 # task_container_environment   = [for k, v in var.task_container_environment : { name = k, value = v }]
  task_container_mount_points  = concat([for v in var.efs_volumes : { containerPath = v.mount_point, readOnly = v.readOnly, sourceVolume = v.name }], var.mount_points)

  log_configuration_options = merge({
    "awslogs-group"         = var.log_group_name != "" ? var.log_group_name : aws_cloudwatch_log_group.this.name,
    "awslogs-region"        = "us-west-2"
    "awslogs-stream-prefix" = "container"
  }, local.log_multiline_pattern)

  container_definition = merge({
    "name"         = var.name
    "image"        = var.image
    "essential"    = true
    "cpu"          = var.container_cpu
    "memory"       = var.container_memory
    "portMappings" = local.task_container_port_mappings
    "stopTimeout"  = var.stop_timeout
    "command"      = var.task_container_command
    "environment"  = var.environment
    "secrets"      = var.secrets
    "MountPoints"  = local.task_container_mount_points
    "linuxParameters"   = var.linux_parameters
    "readonlyRootFilesystem" = var.readonlyRootFilesystem 
    "logConfiguration" = {
      "logDriver" = "awslogs"
      "options"   = local.log_configuration_options
    }
    "privileged" : var.privileged
  },)
}
    
resource "aws_ecs_task_definition" "this" {
  family                   = join("-", [var.name, "task"]) # Naming our first task
  tags = var.tags
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.memory        # Specifying the memory our container requires
  cpu                      = var.cpu         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.execution_role.arn
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
  name = join("-", [var.name, "service"])
  task_definition = "${aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, data.aws_ecs_task_definition.this.revision)}"
  cluster         = var.cluster_arn
  enable_execute_command = var.enable_execute_command
  tags = var.tags
  propagate_tags = "TASK_DEFINITION"
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.name
    container_port   = var.container_port
   
  }

  launch_type                        = "FARGATE"
  desired_count                      = var.desired_count
  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  deployment_controller {
    type = "CODE_DEPLOY"
  }
  deployment_configuration{
  deployment_circuit_breaker{
    enable=true
    rollback=true
  }
    maximum_percent = 100
    minimum_healthy_percent = 100
    
  }
  network_configuration {
    subnets          = var.subnets
    assign_public_ip = var.assign_public_ip # Providing our containers with public IPs
    security_groups   = var.security_groups
  }
  lifecycle {
    ignore_changes = [task_definition,load_balancer,network_configuration]
    # create_before_destroy = true
  }
  

  #depends_on = [var.http_tcp_listener_arns]
}

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "cb_log_group" {
  name              = join("-", [var.name, "ecs-cb"])
  retention_in_days = var.retention_in_days

  tags = var.tags
}

resource "aws_cloudwatch_log_stream" "cb_log_stream" {
  name           = join("-", [var.name, "ecs-log-stream"])
  log_group_name = aws_cloudwatch_log_group.cb_log_group.name
}

## new autoscaling

module "ecs-autoscaling" {
  count = var.enable_autoscaling ? 1 : 0

  source  = "git::https://git@github.com/ucopacme/terraform-aws-ecs-fargate-auto-scaling"
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
