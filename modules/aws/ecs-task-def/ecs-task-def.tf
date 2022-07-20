

resource "aws_ecs_task_definition" "this" {
  family                   = join("-", [var.name, "task"]) # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.name}",
      "image": "${var.image}",
      "essential": true,
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
}


### ECS Services

data "aws_ecs_task_definition" "this" {
  task_definition = aws_ecs_task_definition.this.family
  depends_on      = [aws_ecs_task_definition.this]
}
resource "aws_ecs_service" "this" {
  name = join("-", [var.name, "service"])
  # task_definition = "${aws_ecs_task_definition.this.id}"
  task_definition = "${aws_ecs_task_definition.this.family}:${max("${aws_ecs_task_definition.this.revision}", "${data.aws_ecs_task_definition.this.revision}")}"
  cluster         = var.cluster

  load_balancer {
    target_group_arn = var.target_group_arn
    #target_group_arn = var.target_group_arn
    # target_group_arn = "${aws_lb_target_group.this[0].arn}"
    # target_group_arn = "${aws_lb_target_group.blue.arn}"
    container_name   = "${var.name}"
    container_port   = "${var.containerport}"
   
  }

  launch_type                        = "FARGATE"
  desired_count                      = 2
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_controller {
    type = "CODE_DEPLOY"
  }
  
  network_configuration {
    subnets          = "${var.subnets}"
    assign_public_ip = true # Providing our containers with public IPs
    security_groups   = var.security_groups
  }
  lifecycle {
    ignore_changes = [task_definition,load_balancer,network_configuration]
    # create_before_destroy = true
  }

  #depends_on = [var.http_tcp_listener_arns]
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
