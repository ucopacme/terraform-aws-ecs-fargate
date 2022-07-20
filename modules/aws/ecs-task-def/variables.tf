variable "image" {
  description = "Task def image name"
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

#variable "http_tcp_listener_arns" {
 # description = ""
  #type        = string
#}
