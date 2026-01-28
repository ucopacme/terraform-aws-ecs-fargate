locals {
  task_log_multiline_pattern = var.task_log_multiline_pattern != "" ? { "awslogs-multiline-pattern" = var.task_log_multiline_pattern } : null
  #task_container_secrets       = length(var.task_container_secrets) > 0 ? { "secrets" = var.task_container_secrets } : null
  #repository_credentials       = length(var.repository_credentials) > 0 ? { "repositoryCredentials" = { "credentialsParameter" = var.repository_credentials } } : null
  task_container_port_mappings = var.task_container_port == 0 ? var.task_container_port_mappings : concat(var.task_container_port_mappings, [{ containerPort = var.task_container_port, hostPort = var.task_container_port, protocol = "tcp" }])
  # task_container_environment   = [for k, v in var.task_container_environment : { name = k, value = v }]
  task_container_mount_points = concat([for v in var.efs_volumes : { containerPath = v.mount_point, readOnly = v.readOnly, sourceVolume = v.name }], var.mount_points)

  derived_ecs_hash = var.enable_ecs_cluster ? substr(sha256(aws_ecs_cluster.this[0].name), 0, 8) : ""

  # Generate an empty list if enable_ecs_cluster is false, otherwise set value to var.managed_ec2_providers
  managed_ec2_providers = var.enable_ecs_cluster ? var.managed_ec2_providers : {}
  asg_ec2_providers    = var.enable_ecs_cluster ? var.asg_ec2_providers : {}

  log_configuration_options = merge({
    "awslogs-group"         = aws_cloudwatch_log_group.this.name
    "awslogs-region"        = "us-west-2"
    "awslogs-stream-prefix" = var.awslogs_stream_prefix
  }, local.task_log_multiline_pattern)

  container_definition = merge({
    "name"                   = var.name
    "image"                  = var.image
    "essential"              = true
    "cpu"                    = var.container_cpu
    "memory"                 = var.container_memory
    "portMappings"           = local.task_container_port_mappings
    "stopTimeout"            = var.stop_timeout
    "command"                = var.task_container_command
    "environment"            = var.environment
    "secrets"                = var.secrets
    "systemControls"         = var.systemControls
    "MountPoints"            = local.task_container_mount_points
    "linuxParameters"        = var.linux_parameters
    "readonlyRootFilesystem" = var.readonlyRootFilesystem
    "logConfiguration" = {
      "logDriver" = "awslogs"
      "options"   = local.log_configuration_options
    }
    "privileged" : var.privileged
  }, )
}