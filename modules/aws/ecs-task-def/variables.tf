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
#variable "target_group_arn" {
 # description = "task df cpu"
  #type        = string
#}

#variable "http_tcp_listener_arns" {
 # description = ""
  #type        = string
#}
