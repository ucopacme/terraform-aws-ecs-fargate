variable "name" {
  description = "name, to be used as prefix for all resource names"
  type        = string
}
variable "readonlyRootFilesystem" {
  default     = false
  description = "When this parameter is true, the container is given read-only access to its root file system"
}
variable "containerInsights" {
  description = "Enables container insights if true"
  type        = bool
  default     = false
}
variable "container_cpu" {
  type        = number
  default     = null
  description = "How much CPU to give the container. 1024 is 1 CPU"
}

variable "container_memory" {
  type        = number
  default     = null
  description = "How much memory in megabytes to give the container"
}
variable "task_execution_role_inline_policy" {
  description = "Inline IAM policy to associate with the ECS task execution role"
  default     = ""
  type        = string
}
variable "task_role_inline_policy" {
  description = "Inline IAM policy to associate with the ECS task role"
  default     = ""
  type        = string
}
variable "task_secret_tag_key" {
  description = "AWS tag key for Secrets Manager secrets the ECS task can read"
  default     = "ucop:application"
  type        = string
}
# Ideally this variable should be customized per-use with value to limit
# access to necessary secrets.
variable "task_secret_tag_value" {
  description = "AWS tag value for Secrets Manager secrets the ECS task can read"
  default     = ""
  type        = string
}
variable "enable_ecs_cluster" {
  description = "Set to false to prevent the module from creating ecs cluster"
  type        = bool
  default     = true
}
variable "environment" {
  description = "List of port objects that the container exposes in addition to the task_container_port."
  type = list(object({
    name = string
    value      = string
  }))
  default = []
}
variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "secrets" {
  description = "Hash of name/SecretsManagerARN pairs to include in the task definition as environment variables (see also https://docs.aws.amazon.com/AmazonECS/latest/developerguide/secrets-envvar-secrets-manager.html)"
  type = list(object({
    name = string
    valueFrom = string
  }))
  default = []
}

variable "systemControls" {
  description = "Hash of name/SecretsManagerARN pairs to include in the task definition as environment variables (see also https://docs.aws.amazon.com/AmazonECS/latest/developerguide/secrets-envvar-secrets-manager.html)"
  type = list(object({
    namespace = string
    value = string
  }))
  default = []
}
variable "exec_log_group_name" {
  description = "The name of the provided CloudWatch Logs log group to use for ECS Exec logs."
  default     = ""
  type        = string
}
variable "task_log_group_name" {
  description = "The name of the provided CloudWatch Logs log group to use for ECS task logs."
  default     = ""
  type        = string
}
variable "task_log_multiline_pattern" {
  description = "Optional regular expression. Log messages will consist of a line that matches expression and any following lines that don't"
  default     = ""
  type        = string
}
variable "awslogs_stream_prefix" {
  description = "CloudWatch Logs log stream prefix for ECS task logs."
  default     = "container"
  type        = string
}

variable "image" {
  description = "Task def image name"
  type        = string
}
variable "stop_timeout" {
  description = "Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own. On Fargate the maximum value is 120 seconds."
  default     = 30
}

variable "privileged" {
  description = "When this parameter is true, the container is given elevated privileges on the host container instance"
  default     = false
  type        = bool
}
variable "volumes" {
  description = "List of volume"
  type        = list(any)
  default     = []
}
variable "sidecar_containers" {
  description = "List of sidecar containers"
  type        = list(any)
  default     = []
}

variable "task_container_command" {
  description = "The command that is passed to the container."
  default     = []
  type        = list(string)
}

variable "task_container_port" {
  description = "Port that the container exposes."
  type        = number
  default     = 0
}

variable "retention_in_days" {
  description = "log group retention."
  default     = 30
  type        = number
}
variable "container_name" {
  description = "Name of the container to associate with the load balancer"
  default     = ""
  type        = string
}

variable "container_port" {
  description = "Port that the container exposes."
  type        = number
}

variable "enable_execute_command" {
  description = "Enable ECS Exec, and include IAM actions needed for ECS Exec in task role inline policy"
  type        = bool
  default     = false
}

variable "enable_autoscaling" {
  description = "(Optional) If true, autoscaling alarms will be created."
  type        = bool
  default     = true
}
variable "max_cpu_threshold" {
  description = "Threshold for max CPU usage"
  default     = "85"
  type        = string
}
variable "min_cpu_threshold" {
  description = "Threshold for min CPU usage"
  default     = "10"
  type        = string
}

variable "max_cpu_evaluation_period" {
  description = "The number of periods over which data is compared to the specified threshold for max cpu metric alarm"
  default     = "3"
  type        = string
}
variable "min_cpu_evaluation_period" {
  description = "The number of periods over which data is compared to the specified threshold for min cpu metric alarm"
  default     = "3"
  type        = string
}

variable "max_cpu_period" {
  description = "The period in seconds over which the specified statistic is applied for max cpu metric alarm"
  default     = "60"
  type        = string
}
variable "min_cpu_period" {
  description = "The period in seconds over which the specified statistic is applied for min cpu metric alarm"
  default     = "60"
  type        = string
}

variable "scale_target_max_capacity" {
  description = "The max capacity of the scalable target"
  default     = 2
  type        = number
}

variable "scale_target_min_capacity" {
  description = "The min capacity of the scalable target"
  default     = 1
  type        = number
}

variable "task_container_port_mappings" {
  description = "List of port objects that the container exposes in addition to the task_container_port."
  type = list(object({
    containerPort = number
    hostPort      = number
    protocol      = string
  }))
  default = []
}

variable "efs_volumes" {
  description = "Volumes definitions"
  default     = []
  type = list(object({
    name            = string
    file_system_id  = string
    root_directory  = string
    mount_point     = string
    readOnly        = bool
    access_point_id = string
  }))
}
variable "mount_points" {
  description = "List of mount points"
  type        = list(any)
  default     = []
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 0
}

variable "assign_public_ip" {
  description = "Assign a public IP address to the ENI"
  type        = bool
  default     = false
}

variable "deployment_maximum_percent" {
  description = ""
  type        = string
}

variable "deployment_minimum_healthy_percent" {
  description = ""
  type        = string
}

variable "health_check_grace_period_seconds" {
  description = ""
  type        = number
  default     = 0
}

variable "cluster_arn" {
  description = "name, to be used as prefix for all resource names"
  type        = string
}
variable "cluster_name" {
  description = "The resource name."
  type        = string
  default     = null
}
variable "security_groups" {
  description = "The security groups to attach to the ecs. e.g. [\"sg-edcd9784\",\"sg-edcd9785\"]"
  type        = list(string)
  default     = []
}


variable "memory" {
  description = "task df memory"
  type        = string
}
variable "cpu" {
  description = "task df cpu"
  type        = string
}

variable "subnets" {
  description = "A list of subnets to associate with the ecs . e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"
  type        = list(string)
}


variable "target_group_arn" {
  description = "target group arn"
  type        = string
}


variable "linux_parameters" {
  type = object({
    initProcessEnabled = bool
  })
  description = "Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. For more details, see https://docs.aws.amazon.com/AmazonECS/latest/APIReference/API_LinuxParameters.html"
  default     = null
}
