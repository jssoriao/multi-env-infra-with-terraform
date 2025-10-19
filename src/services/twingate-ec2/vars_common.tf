variable "project_name" {
  description = "Name of this project"
  type        = string
}

variable "aws_region" {
  description = "AWS region where these resources will be deployed"
  type        = string
}

variable "environment" {
  description = "Name of this environment"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
