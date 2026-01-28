
# Managed EC2 Instances Capacity Provider
resource "aws_ecs_capacity_provider" "managed" {
  for_each = local.managed_ec2_providers
  name     = join("-", ["managed", each.key, local.derived_ecs_hash])
  cluster  = aws_ecs_cluster.this[0].name

  managed_instances_provider {
    infrastructure_role_arn = aws_iam_role.ecs_infrastructure_role.arn
    propagate_tags          = "CAPACITY_PROVIDER"

    instance_launch_template {
      ec2_instance_profile_arn = aws_iam_instance_profile.ecs_instance_profile.arn
      monitoring               = "BASIC"

      network_configuration {
        security_groups = var.security_groups
        subnets         = var.subnets
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
          max = each.value.cpu_max != null ? each.value.cpu_max : 2
        }
        instance_generations = ["current"]
        cpu_manufacturers    = ["intel", "amd"]
      }
    }
  }

  tags = var.tags
}
