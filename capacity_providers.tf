resource "aws_iam_role" "ecs_infrastructure_role" {
    name = "ecsInfrastructureRole-managed-ec2"
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
    name = "ECSInfrastructurePassRole"
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
    name = "ecsInstanceProfileRole-managed-ec2"
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
    name = "ecsInstanceProfile-managed-ec2"
    role = aws_iam_role.ecs_instance_role.name
}
# ResourceInitializationError: Unable to launch instance(s) for capacity provider PUBSUB. UnauthorizedOperation: You are not authorized to perform this operation. User: arn:aws:sts::933103158638:assumed-role/ecsInfrastructureRole-managed-ec2/ECSManagedInstances is not authorized to perform: iam:PassRole on resource: arn:aws:iam::933103158638:role/ecsInstanceProfileRole-managed-ec2 because no identity-based policy allows the iam:PassRole action.
resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy_attachment" {
    for_each = toset([
        # Copy ucop default without the bootstrap policy
        "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess",
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
        "arn:aws:iam::aws:policy/AWSQuickSetupPatchPolicyBaselineAccess",
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
        "arn:aws:iam::aws:policy/AmazonECSInstanceRolePolicyForManagedInstances"
    ])
    role       = aws_iam_role.ecs_instance_role.name
    policy_arn = each.value
}

resource "aws_ecs_capacity_provider" "this" {
    for_each = local.managed_ec2_instances
    name = each.key
    cluster = aws_ecs_cluster.this[0].name

    managed_instances_provider {
        infrastructure_role_arn = aws_iam_role.ecs_infrastructure_role.arn
        propagate_tags = "CAPACITY_PROVIDER"

        instance_launch_template {
            ec2_instance_profile_arn = aws_iam_instance_profile.ecs_instance_profile.arn
            monitoring = "BASIC"

            network_configuration {
                security_groups = var.security_groups
                subnets = var.subnets
            }

            storage_configuration {
                storage_size_gib = each.value.storage_gb != null ? each.value.storage_gb : 30
            }

            instance_requirements {
                memory_mib {
                    min = 1024
                    max = each.value.mem_max != null ? each.value.mem_max : 4096
                }
                vcpu_count {
                    min = 1
                    max =  each.value.cpu_max != null ? each.value.cpu_max : 2
                }
                instance_generations = ["current"]
                cpu_manufacturers = ["intel", "amd"]
            }
        }
    }

    tags = var.tags
}