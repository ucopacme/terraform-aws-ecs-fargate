data "aws_ecs_task_definition" "this" {
  task_definition = "${aws_ecs_task_definition.this.family}"
}
resource "aws_ecs_service" "this" {
  name            = "${var.service_name}"
  # task_definition = "${aws_ecs_task_definition.this.id}"
  task_definition = "${aws_ecs_task_definition.this.family}:${max("${aws_ecs_task_definition.this.revision}", "${data.aws_ecs_task_definition.this.revision}")}"
  cluster         = "${aws_ecs_cluster.this.arn}"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.this[0].arn}"
    # target_group_arn = "${aws_lb_target_group.blue.arn}"
    container_name   = "${var.service_name}"
    container_port   = "${var.container_port}"
  }

  launch_type                        = "FARGATE"
  desired_count                      = 2
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_controller {
    type = "CODE_DEPLOY"
  }
  
  network_configuration {
    subnets          = ["subnet-0c0dbee3b7b03e4e2", "subnet-0fd7ec9b1f3cdd68d"]
    assign_public_ip = true # Providing our containers with public IPs
    security_groups   = [aws_security_group.service_security_group.id]
  }
  lifecycle {
    ignore_changes = [task_definition,load_balancer,network_configuration]
    # create_before_destroy = true
  }

  depends_on = [aws_lb_listener.this]
}

resource "aws_security_group" "service_security_group" {
  name = "kk-ecs-test"
  vpc_id      = "vpc-06a0bfef01b9d0e7b"
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.alb.id}"]
  }

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}
