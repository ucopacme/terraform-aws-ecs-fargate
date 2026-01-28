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
resource "aws_launch_template" "ecs_asg_providers" {
  for_each      = local.asg_ec2_providers
  name_prefix   = join("-", ["ecs", local.derived_ecs_hash])
  image_id      = data.aws_ami.ecs_optimized_al2023.id
  instance_type = local.asg_ec2_providers[each.key].instance_type != null ? local.asg_ec2_providers[each.key].instance_type : "m7a.medium"
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

    tags = var.tags
  }
}

# asg for instances
resource "aws_autoscaling_group" "ecs_asg_provider" {
  for_each              = local.asg_ec2_providers
  name                  = join("-", ["ecs", each.key, local.derived_ecs_hash])
  max_size              = each.value.max_capacity != null ? each.value.max_capacity : 2
  min_size              = each.value.min_capacity != null ? each.value.min_capacity : 0
  desired_capacity      = each.value.desired_capacity != null ? each.value.desired_capacity : each.value.min_capacity != null ? each.value.min_capacity : 0
  protect_from_scale_in = true
  launch_template {
    id      = aws_launch_template.ecs_asg_providers[each.key].id
    version = "$Latest"
  }
  vpc_zone_identifier       = var.subnets
  health_check_type         = "EC2"
  health_check_grace_period = 300

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = false
    }
  }
}

# capacity provider
resource "aws_ecs_capacity_provider" "asg" {
  for_each = local.asg_ec2_providers
  name     = join("-", ["asg", each.key, local.derived_ecs_hash])
  # Cluster is defined via asg userdata
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg_provider[each.key].arn
    managed_termination_protection = "ENABLED"
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 75
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1000
    }
  }

  tags = merge(
    var.tags,
    {
      ECSCluster = aws_ecs_cluster.this[0].name
    }
  )
}

#TODO: Add ci to auto-rotate asg ami monthly
#TODO: Add asg template deployment strategy for blue/green deployments
