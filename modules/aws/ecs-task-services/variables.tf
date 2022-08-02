variable "image" {
  description = "Task def image name"
  type        = string
}

#variable "container_mount_path" {
 # description = "Task def image name"
  #type        = any
#}

variable "mount_points" {
type = string
}
variable "efs_file_system_id" {
  description = "Task def image name"
  type        = string
}
variable "desired_count" {
  description = ""
  type        = string
}
variable "min_capacity" {
  description = ""
  type        = string
}

variable "max_capacity" {
  description = ""
  type        = string
}
variable "threshold_high" {
  description = ""
  type        = string
}
variable "threshold_low" {
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

variable "containerport" {
  description = "Container port number"
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
variable "hostport" {
  description = "Host port number"
  type        = string
}

variable "execution_role_arn" {
  description = "ECS execution role arn"
  type        = string
}

variable "name" {
  type       = string
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

variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources"
  type        = map(string)
}
