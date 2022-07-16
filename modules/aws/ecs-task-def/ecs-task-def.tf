resource "aws_ecs_task_definition" "this" {
  family                   = "my-first-task-demo" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.name}",
      "image": "944706592399.dkr.ecr.us-west-2.amazonaws.com/iam-idp-ecr-repo",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 443,
          "hostPort": 443
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn                   = 256         # Specifying the CPU our container requires
  execution_role_arn       = var.execution_role_arn
}
