
resource "aws_cloudwatch_log_group" "this" {
  name              = join("-", [var.name, "ecs-task-lg"])
  retention_in_days = 30

  tags = var.tags
}

resource "aws_cloudwatch_log_stream" "this" {
  name           = join("-", [var.name, "ecs-task-ls"])
  log_group_name = aws_cloudwatch_log_group.this.name
}
resource "aws_ecs_task_definition" "this" {
  family                   = join("-", [var.name, "task"]) # Naming our first task
  tags = var.tags
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.name}",
      "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-region" : "us-west-2",
                    "awslogs-group" : "${aws_cloudwatch_log_group.this.name}",
                    "awslogs-stream-prefix" : "ecs"
                }
            },
      "image": "${var.image}",
      "essential": true,
      "mountPoints": [
          {
              "containerPath": "${var.mount_points}",
              "sourceVolume": "${var.volume_name}"
          }
      ],
      "portMappings": [
        {
          "containerPort": ${var.containerport},
          "hostPort": ${var.hostport}
        }
      ],
      "memory": ${var.memory},
      "cpu": ${var.cpu}
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.memory        # Specifying the memory our container requires
  cpu                      = var.cpu         # Specifying the CPU our container requires
  execution_role_arn       = var.execution_role_arn
  volume {
    name = var.volume_name
    efs_volume_configuration {
      file_system_id = var.efs_file_system_id
      root_directory = var.root_directory

    }
  }
}


### ECS Services

data "aws_ecs_task_definition" "this" {
  task_definition = aws_ecs_task_definition.this.family
  depends_on      = [aws_ecs_task_definition.this]
}
resource "aws_ecs_service" "this" {
  name = join("-", [var.name, "service"])
  # task_definition = "${aws_ecs_task_definition.this.id}"
  task_definition = "${aws_ecs_task_definition.this.family}:${max(aws_ecs_task_definition.this.revision, data.aws_ecs_task_definition.this.revision)}"
  cluster         = var.cluster
  tags = var.tags

  load_balancer {
    target_group_arn = var.target_group_arn
    #target_group_arn = var.target_group_arn
    # target_group_arn = "${aws_lb_target_group.this[0].arn}"
    # target_group_arn = "${aws_lb_target_group.blue.arn}"
    container_name   = var.name
    container_port   = var.containerport
   
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

# auto_scaling



resource "aws_appautoscaling_target" "target" {
  service_namespace  = "ecs"
  resource_id = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  #role_arn           = aws_iam_role.autoscaling_role.arn
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "up" {
  name               = join("-", [var.name, "cb_scale_up"])
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "down" {
  name               = join("-", [var.name, "cb_scale_dwon"])
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.target]
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = join("-", [var.name, "cb_cpu_utilization_high"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.threshold_high

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [aws_appautoscaling_policy.up.arn]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = join("-", [var.name, "cb_cpu_utilization_low"])
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = var.threshold_low

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.this.name
  }

  alarm_actions = [aws_appautoscaling_policy.down.arn]
}
# resource "aws_security_group" "service_security_group" {
#   name = "kk-ecs-test"
#   vpc_id      = "vpc-06a0bfef01b9d0e7b"
#   ingress {
#     from_port = 0
#     to_port   = 0
#     protocol  = "-1"
#     # Only allowing traffic in from the load balancer security group
#     security_groups = [""]
#   }

#   egress {
#     from_port   = 0 # Allowing any incoming port
#     to_port     = 0 # Allowing any outgoing port
#     protocol    = "-1" # Allowing any outgoing protocol 
#     cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
#   }
# }
