# EC2 Capacity Provider
# data lookup for latest ecs optimized al2023 ami
data "aws_ami" "ecs_optimized_al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-2023.0.*-kernel-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# launch template for instances, should include userdata to set cluster name to match this cluster
resource "aws_launch_template" "ecs_asg_instances" {
  for_each = local.asg_ec2_instances
  name_prefix   = join("-", [aws_ecs_cluster.this[0].name, "ecs-managed-instances-"])
  image_id      = data.aws_ami.ecs_optimized_al2023.id
  instance_type = local.asg_ec2_instances[each.key].instance_type != null ? local.asg_ec2_instances[each.key].instance_type : "m7a.medium"

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.this[0].name} >> /etc/ecs/ecs.config
EOF
  )
    network_interfaces {
        associate_public_ip_address = false
        security_groups             = var.security_groups
        subnet_id                   = element(var.subnets, 0)
    }
    tag_specifications {
        resource_type = "instance"

        tags = merge(
            var.tags,
            {
                Name = join("-", [aws_ecs_cluster.this[0].name, "ecs-ec2-instance"])
            }
        )
    }
}

# asg for instances
resource "aws_autoscaling_group" "ecs_asg_instances" {
    for_each = local.asg_ec2_instances
    name                      = join("-", [aws_ecs_cluster.this[0].name, "ecs-managed-instances", each.key])
    max_size                  = each.value.max_capacity != null ? each.value.max_capacity : 2
    min_size                  = each.value.min_capacity != null ? each.value.min_capacity : 1
    desired_capacity          = each.value.desired_capacity != null ? each.value.desired_capacity : each.value.min_capacity != null ? each.value.min_capacity : 1
    launch_template {
        id      = aws_launch_template.ecs_asg_instances[each.key].id
        version = "$Latest"
    }
    vpc_zone_identifier       = var.subnets
    health_check_type         = "EC2"
    health_check_grace_period = 300
}

# capacity provider
resource "aws_ecs_capacity_provider" "ec2_capacity_provider" {
  for_each = local.asg_ec2_instances
  name    = join("-", [aws_ecs_cluster.this[0].name, each.key, "EC2CapacityProvider"])
  cluster = aws_ecs_cluster.this[0].name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg_instances[each.key].arn
    managed_termination_protection = "ENABLED"
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 75
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1000
    }
  }
  
  tags = var.tags
}