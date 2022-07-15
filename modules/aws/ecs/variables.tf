variable "name" {
  description = "name, to be used as prefix for all resource names"
  type        = string
}
variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources"
  type        = map(string)
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "alb_sg" {
  description = "The security groups to attach to the load balancer. e.g. [\"sg-edcd9784\",\"sg-edcd9785\"]"
  type        = list(string)
  default     = []
}