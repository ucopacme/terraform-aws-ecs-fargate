resource "aws_iam_role" "ecs_infrastructure_role" {
    name = join("-", [aws_ecs_cluster.this.name, "ecsInfrastructureRole", "managed-ec2"])
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
    name = join("-", [aws_ecs_cluster.this.name, "ecsInfrastructurePassRole", "managed-ec2"])
    role = aws_iam_role.ecs_infrastructure_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = "iam:PassRole"
                Resource = aws_iam_role.ecs_instance_role.arn
            }
        ]
    })
}

resource "aws_iam_role" "ecs_instance_role" {
    name = join("-", [aws_ecs_cluster.this.name, "ecsInstanceProfileRole", "managed-ec2"])
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
    name = join("-", [aws_ecs_cluster.this.name, "ecsInstanceProfile", "managed-ec2"])
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
