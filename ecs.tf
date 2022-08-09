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
      "ecs:DescribeClusters"
    ]

    resources = ["*"]
  }
}

#data "aws_iam_policy_document" "task_role" {
 # statement {
  #  sid    = "AllowDescribeCluster"
   # effect = "Allow"

    #actions = ["ecs:DescribeClusters"]

    #resources = [aws_ecs_cluster.this.arn]
  #}
#}

resource "aws_iam_role" "execution_role" {
  name               = "${var.name}_ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
}

resource "aws_iam_role_policy" "execution_role" {
  role   = aws_iam_role.execution_role.name
  policy = data.aws_iam_policy_document.execution_role.json
}

#resource "aws_iam_role" "task_role" {
# name               = "${var.name}_ecsTaskRole"
 # assume_role_policy = data.aws_iam_policy_document.assume_by_ecs.json
#}

#resource "aws_iam_role_policy" "task_role" {
 # role   = aws_iam_role.task_role.name
  #policy = data.aws_iam_policy_document.task_role.json
#}

resource "aws_ecs_cluster" "this" {
  name = join("-", [var.name, "cluster"])
  tags = var.tags
}



resource "aws_cloudwatch_log_group" "this" {
  name              = join("-", [var.name, "ecs-task-lg"])
  retention_in_days = 30

  tags = var.tags
}

resource "aws_cloudwatch_log_stream" "this" {
  name           = join("-", [var.name, "ecs-task-ls"])
  log_group_name = aws_cloudwatch_log_group.this.name
}

locals {
  log_multiline_pattern        = var.log_multiline_pattern != "" ? { "awslogs-multiline-pattern" = var.log_multiline_pattern } : null
  #task_container_secrets       = length(var.task_container_secrets) > 0 ? { "secrets" = var.task_container_secrets } : null
  #repository_credentials       = length(var.repository_credentials) > 0 ? { "repositoryCredentials" = { "credentialsParameter" = var.repository_credentials } } : null
  task_container_port_mappings = var.task_container_port == 0 ? var.task_container_port_mappings : concat(var.task_container_port_mappings, [{ containerPort = var.task_container_port, hostPort = var.task_container_port, protocol = "tcp" }])
 # task_container_environment   = [for k, v in var.task_container_environment : { name = k, value = v }]
  task_container_mount_points  = concat([for v in var.efs_volumes : { containerPath = v.mount_point, readOnly = v.readOnly, sourceVolume = v.name }], var.mount_points)

  log_configuration_options = merge({
    "awslogs-group"         = var.log_group_name != "" ? var.log_group_name : aws_cloudwatch_log_group.main.0.name,
    "awslogs-region"        = data.aws_region.current.name
    "awslogs-stream-prefix" = "container"
  }, local.log_multiline_pattern)

  container_definition = merge({
    "name"         = var.name
    "image"        = var.image,
    "essential"    = true
    "portMappings" = local.task_container_port_mappings
    "stopTimeout"  = var.stop_timeout
    "command"      = var.task_container_command
    "MountPoints"  = local.task_container_mount_points
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
  cluster         = aws_ecs_cluster.this.arn
  tags = var.tags

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
  retention_in_days = 30

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
  ecs_cluster_name          = aws_ecs_cluster.this.name
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
