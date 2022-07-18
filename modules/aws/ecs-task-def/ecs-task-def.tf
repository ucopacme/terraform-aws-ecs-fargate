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
      "cpu": ${var.cpy}
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = var.memory}         # Specifying the memory our container requires
  cpu                      = var.cpu         # Specifying the CPU our container requires
  execution_role_arn       = var.execution_role_arn
}
