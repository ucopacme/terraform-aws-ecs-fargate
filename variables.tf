variable "name" {
  description = "name, to be used as prefix for all resource names"
  type        = string
}
variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "alb_sg" {
  description = "The security groups to attach to the load balancer. e.g. [\"sg-edcd9784\",\"sg-edcd9785\"]"
  type        = list(string)
  default     = []
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

variable "container_port" {
  description = "Port that the container exposes."
  type        = number
 
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

variable "task_container_protocol" {
  description = "Protocol that the container exposes."
  default     = "HTTP"
  type        = string
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
variable "efs_file_system_id" {
  description = "Task def image name"
  type        = string
  default = ""
}
variable "volume_name" {
type = string
default = ""
}

variable "root_directory" {
type = string
default = ""
}

variable "desired_count" {
  description = ""
  type        = string
}

variable "assign_public_ip" {
  description = ""
  type   = string
  default = "false"
}

variable "deployment_maximum_percent" {
  description = ""
  type        = string
}

variable "deployment_minimum_healthy_percent" {
  description = ""
  type        = string
}

variable "cluster" {
  description = "The resource name."
  type        = string
  default     = null
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

variable "vpc_id" {
  description = "VPC id where the load balancer and other resources will be deployed."
  type        = string
  default     = null
}
variable "subnets" {
  description = "A list of subnets to associate with the ecs . e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f']"
  type        = list(string)
}


variable "target_group_arn" {
  description = "task df cpu"
  type        = string
}

