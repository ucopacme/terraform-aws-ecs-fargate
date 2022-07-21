data "aws_iam_policy_document" "assume_by_codedeploy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codedeploy" {
  name               = "${var.name}-codedeploy"
  assume_role_policy = "${data.aws_iam_policy_document.assume_by_codedeploy.json}"
}

data "aws_iam_policy_document" "codedeploy" {
  statement {
    sid    = "AllowLoadBalancingAndECSModifications"
    effect = "Allow"

    actions = [
      "ecs:CreateTaskSet",
      "ecs:DeleteTaskSet",
      "ecs:DescribeServices",
      "ecs:UpdateServicePrimaryTaskSet",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyRule",
      "lambda:InvokeFunction",
      "cloudwatch:DescribeAlarms",
      "sns:Publish",
      "s3:GetObject",
      "s3:GetObjectMetadata",
      "s3:GetObjectVersion"
    ]

    resources = ["*"]
  }
  
  statement {
    sid = "AllowCodecommit"
    effect = "Allow"

    actions = [
      "codecommit:*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowPassRole"
    effect = "Allow"

    actions = ["iam:PassRole"]

    resources = [
      "arn:aws:iam::944706592399:role/chs-dev-ecs_ecsTaskExecutionRole",
      "arn:aws:iam::944706592399:role/chs-dev-ecs_ecsTaskRole",
    ]
  }
}

resource "aws_iam_role_policy" "codedeploy" {
  role   = "${aws_iam_role.codedeploy.name}"
  policy = "${data.aws_iam_policy_document.codedeploy.json}"
}

resource "aws_codedeploy_app" "this" {
  compute_platform = "ECS"
  name             = "${var.name}-service-deploy"
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = "${aws_codedeploy_app.this.name}"
  deployment_group_name  = "${var.name}-service-deploy-group"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = "${aws_iam_role.codedeploy.arn}"

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  ecs_service {
    cluster_name = "chs-dev-ecs-cluster"
    service_name = "chs-dev-service"
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = ["arn:aws:elasticloadbalancing:us-west-2:944706592399:listener/app/test-dev-alb/9cadac78a79001a0/bf6dd2a5634660a4"]
      }

      target_group {
        name = "test-dev-0-alb-tg"
        # name = "${aws_lb_target_group.blue.name}"
      }

      target_group {
        name = "test-dev-1-alb-tg"
        # name = "${aws_lb_target_group.green.name}"
      }
      
    }
  # lifecycle { ignore_changes = [blue_green_deployment_config] }
  }
}
