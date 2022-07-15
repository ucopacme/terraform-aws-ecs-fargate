locals {
  target_groups = ["blue", "green"]
  hosts_name = ["*.yourdomain.com"] #example : fill your information
}

resource "aws_security_group" "alb" {
  name   = "${var.service_name}-allow-http"
  vpc_id = "vpc-06a0bfef01b9d0e7b"

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["128.48.0.0/16"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.service_name}-allows-http"
  }
}

resource "aws_lb" "this" {
  name               = "${var.service_name}-service-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb.id}"]
  subnets            = [
    "subnet-0ece5975ca259796e",
    "subnet-084c56f1fd8699660"
  
  ]

  tags = {
    "ucop:application" = "test"
    "ucop:createdBy"   = "terraform"
    "ucop:enviroment"  = "dev"
    "ucop:group"       = "test"
    Name = "${var.service_name}-service-alb"
  }
}

resource "aws_lb_target_group" "this" {
  count = "${length(local.target_groups)}"
  name  = "${var.service_name}-tg-${element(local.target_groups, count.index)}"

  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-06a0bfef01b9d0e7b"
  target_type = "ip"

  health_check {
    path = "/"
  }
}

# resource "aws_lb_target_group" "blue" {
#   name  = "${var.service_name}-tg-blue"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = "vpc-06a0bfef01b9d0e7b"
#   target_type = "ip"

#   health_check {
#     path = "/"
#   }
# }

# resource "aws_lb_target_group" "green" {
#   name  = "${var.service_name}-tg-green"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = "vpc-06a0bfef01b9d0e7b"
#   target_type = "ip"

#   health_check {
#     path = "/"
#   }
# }

resource "aws_lb_listener" "this" {
  load_balancer_arn = "${aws_lb.this.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    # target_group_arn = "${aws_lb_target_group.blue.arn}"
    target_group_arn = "${aws_lb_target_group.this.0.arn}"
  }
  lifecycle {
    ignore_changes = [
      default_action
    ]
  }
}

# resource "aws_lb_listener" "thiss" {
#   load_balancer_arn = "${aws_lb.this.arn}"
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     # target_group_arn = "${aws_lb_target_group.blue.arn}"
#     target_group_arn = "${aws_lb_target_group.this.1.arn}"
#   }
# }
resource "aws_lb_listener_rule" "this" {
  count        = 2
  listener_arn = "${aws_lb_listener.this.arn}"

  action {
    type             = "forward"
    # target_group_arn = "${aws_lb_target_group.this.*.arn[count.index]}"
    # target_group_arn = "${aws_lb_target_group.blue.arn}"
    target_group_arn = "${aws_lb_target_group.this.0.arn}"
  }

  condition {
    host_header {
    values = "${local.hosts_name}"
      
    }
    
  }
  lifecycle {
  ignore_changes = [
    action
  ]
  }
    
}
  

