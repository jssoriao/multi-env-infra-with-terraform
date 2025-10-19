variable "name" {
  description = "Name of the twingate connector instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the twingate connector instance will be deployed"
  type        = string
}

variable "instances" {
  description = "Map of twingate connector instances configuration"
  type = map(object({
    subnet_id               = string
    instance_type           = string
    use_spot_instance       = optional(bool, false)
    spot_max_price          = optional(number, null)
    spot_type               = optional(string, "one-time")
    network                 = string # Name of the twingate network (e.g. wearefour) to be prepended to the twingate URL to form wearefour.twingate.com.
    connector_access_token  = string
    connector_refresh_token = string
  }))
}

variable "ebs_kms_key_id" {
  description = "KMS key ID for EBS encryption"
  type        = string
}

variable "additional_role_policy_arns" {
  description = "Additional IAM policy ARNs to attach to the instance role"
  type        = list(string)
  default     = []
}

variable "additional_security_groups" {
  description = "List of additional security group IDs to associate with the twingate connector instance"
  type        = list(string)
  default     = []
}
