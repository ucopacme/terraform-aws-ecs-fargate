resource "aws_iam_role" "ecs_infrastructure_role" {
  name = join("-", ["ecsInfrastructureRole", "capacity-provider", local.derived_ecs_hash])
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_infrastructure_role_policy_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForVolumes",
    "arn:aws:iam::aws:policy/service-role/AmazonECSInfrastructureRolePolicyForServiceConnectTransportLayerSecurity",
    "arn:aws:iam::aws:policy/AmazonECSInfrastructureRolePolicyForManagedInstances"
  ])
  role       = aws_iam_role.ecs_infrastructure_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "ecs_infrastructure_pass_role" {
  name = join("-", ["ecsInfrastructurePassRole", "capacity-provider", local.derived_ecs_hash])
  role = aws_iam_role.ecs_infrastructure_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = aws_iam_role.ecs_instance_role.arn
      }
    ]
  })
}

resource "aws_iam_role" "ecs_instance_role" {
  name = join("-", ["ecsInstanceProfileRole", "capacity-provider", local.derived_ecs_hash])
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "ecs.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = join("-", ["ecsInstanceProfile", "capacity-provider", local.derived_ecs_hash])
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AWSQuickSetupPatchPolicyBaselineAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonECSInstanceRolePolicyForManagedInstances"
  ])
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = each.value
}

resource "aws_ecs_cluster_capacity_providers" "ecs_capacity_providers" {
  cluster_name = aws_ecs_cluster.this[0].name

  #TODO: This doesn't disassociate ASG from the capacity providers before trying to delete them, causing errors on destroy.
  capacity_providers = concat(
    ["FARGATE"],
    length(local.managed_ec2_providers) > 0 ? [for cp in aws_ecs_capacity_provider.managed : cp.name] : [],
    length(local.asg_ec2_providers) > 0 ? [for cp in aws_ecs_capacity_provider.asg : cp.name] : []
  )

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}
