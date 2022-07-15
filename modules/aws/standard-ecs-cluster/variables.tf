#example : fill your information
variable "name" {
  description = "name, to be used as prefix for all resource names"
  type        = string
}
variable "tags" {
  default     = {}
  description = "A map of tags to add to all resources"
  type        = map(string)
}
variable "region" {
  default = "us-west-2"
}

provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "${var.region}"
}

variable "ecs_key_pair_name" {
  default = ""
}

variable "aws_account_id" {
  default = ""
}

variable "service_name" {
  default = "demo-service"
}

variable "container_port" {
  default = "80"
}

variable "memory_reserv" {
  default = 212
}