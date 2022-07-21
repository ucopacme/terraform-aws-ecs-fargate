variable "name" {
  type       = string
}


variable "cluster_name" {
  description = "The resource name."
  type        = string
  default     = null
}

variable "service_name" {
  description = "The resource name."
  type        = string
  default     = null
}

variable "aws_account_id" {
  default = ""
}

variable "region" {
  default = "us-west-2"
}
