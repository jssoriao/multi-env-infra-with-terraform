variable "name" {
  description = "Name of the fck-nat instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the fck-nat instances will be deployed"
  type        = string
}

variable "ha_mode" {
  description = "Whether to use AWS ASG for high availability"
  type        = bool
  default     = false
}

variable "encryption" {
  description = "Whether to enable encryption for the instance EBS"
  type        = bool
  default     = true
}

variable "ebs_kms_key_id" {
  description = "Optional KMS key ID for EBS encryption"
  type        = string
  default     = null
}

variable "ssm_kms_key_id" {
  description = "Optional KMS key ID for SSM encryption"
  type        = string
  default     = null
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs to assign to fck-nat instances"
  type        = list(string)
  default     = []
}

variable "instance_type" {
  description = "EC2 instance type for fck-nat"
  type        = string
  default     = "t4g.nano"
}

variable "ebs_root_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 8
}

variable "ami_id" {
  description = "AMI ID for fck-nat instance. If not provided, will use the latest fck-nat AMI"
  type        = string
  default     = null
}

variable "instances" {
  description = "Map of fck-nat instances configuration"
  type = map(object({
    subnet_id         = string
    route_table_ids   = list(string)
    eip               = optional(string)
    attach_eip        = optional(bool, true)
    use_spot_instance = optional(bool, false)
    spot_max_price    = optional(number, null)
  }))
}

variable "use_cloudwatch_agent" {
  description = "Whether or not to enable CloudWatch agent for the NAT instance"
  type        = bool
  default     = false
}

variable "cloudwatch_agent_configuration" {
  description = "CloudWatch configuration for the NAT instance"
  type = object({
    namespace           = optional(string, "fck-nat"),
    collection_interval = optional(number, 60),
    endpoint_override   = optional(string, "")
  })
  default = {
    namespace           = "fck-nat"
    collection_interval = 60
    endpoint_override   = ""
  }
}

variable "cloudwatch_agent_configuration_param_arn" {
  description = "ARN of the SSM parameter containing the CloudWatch agent configuration. If none provided, creates one"
  type        = string
  default     = null
}

variable "update_route_tables" {
  description = "Whether to update the route tables"
  type        = bool
  default     = true
}

variable "security_group_tags" {
  description = "Tags for the security group"
  type        = map(string)
  default     = {}
}

variable "instance_tags" {
  description = "Tags for the EC2 instance"
  type        = map(string)
  default     = {}
}

variable "eni_tags" {
  description = "Tags for the network interface"
  type        = map(string)
  default     = {}
}

variable "eip_tags" {
  description = "Tags for the EIP"
  type        = map(string)
  default     = {}
}

variable "volume_tags" {
  description = "Tags for the EBS volumes"
  type        = map(string)
  default     = {}
}

variable "instance_role_tags" {
  description = "Tags for the EC2 instance role"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "additional_role_policy_statements" {
  description = "Additional IAM role policy statements to add to the instance role"
  type = list(object({
    sid       = string
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  default = []
}

variable "additional_role_policy_arns" {
  description = "Additional IAM policy ARNs to attach to the instance role"
  type        = list(string)
  default     = []
}
