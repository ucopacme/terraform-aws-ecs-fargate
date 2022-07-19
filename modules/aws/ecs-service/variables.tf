variable "name" {
  description = "The resource name."
  type        = string
  default     = null
}

variable "cluster" {
  description = "The resource name."
  type        = string
  default     = null
}

variable "containerport" {
  default = "443"
}
