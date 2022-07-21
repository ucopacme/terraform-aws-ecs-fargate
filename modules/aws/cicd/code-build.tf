data "aws_iam_policy_document" "assume_by_codebuild" {
  statement {
    sid     = "AllowAssumeByCodebuild"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "${var.name}-codebuild"
  assume_role_policy = "${data.aws_iam_policy_document.assume_by_codebuild.json}"
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowECR"
    effect = "Allow"

    actions = [
      "ecr:*"
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
    sid    = "AWSKMSUse"
    effect = "Allow"

    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]

    resources = ["*"]
  }

  statement {
    sid       = "AllowECSDescribeTaskDefinition"
    effect    = "Allow"
    actions   = ["ecs:DescribeTaskDefinition"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowLogging"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild" {
  role   = "${aws_iam_role.codebuild.name}"
  policy = "${data.aws_iam_policy_document.codebuild.json}"
}

resource "aws_codebuild_project" "this" {
  name         = "${var.name}-codebuild"
  description  = "Codebuild for the ECS Green/Blue ${var.name} app"
  service_role = "${aws_iam_role.codebuild.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "944706592399.dkr.ecr.us-west-2.amazonaws.com/ecs-last-test"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${var.aws_account_id}"
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "${var.region}"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "SERVICE_PORT"
      value = 80
    }

    environment_variable {
      name  = "MEMORY_RESV"
      value = 512
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec = "buildspec.yml"
    
  }
}
