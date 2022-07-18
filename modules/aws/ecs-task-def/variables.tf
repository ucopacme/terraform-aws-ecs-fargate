variable "image" {
  description = "Prefix (eg. abc) of the instance profile (abcProfile) and role (abcRole) names"
  type        = string
}

variable "containerport" {
  description = "Prefix (eg. abc) of the instance profile (abcProfile) and role (abcRole) names"
  type        = number
}

variable "hostport" {
  description = "Prefix (eg. abc) of the instance profile (abcProfile) and role (abcRole) names"
  type        = number
}

variable "execution_role_arn" {
  description = "Prefix (eg. abc) of the instance profile (abcProfile) and role (abcRole) names"
  type        = string
}

variable "name" {
  default = "demo-ecs"
}
