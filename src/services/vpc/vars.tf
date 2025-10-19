#######
# VPC #
#######

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "create_redshift_subnets" {
  description = "Whether to create Amazon Redshift subnets"
  type        = bool
  default     = false
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`"
  type        = bool
  default     = false
}

###############
# Flow Log S3 #
###############

variable "enable_flow_log_s3" {
  description = "Whether or not to enable VPC Flow Logs in S3"
  type        = bool
  default     = false
}

variable "flow_logs_s3_kms_key_id" {
  description = "ID of the KMS key to use for flow logs S3 encryption"
  type        = string
  default     = null
}

variable "flow_logs_bucket_lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management for the flow logs bucket"
  type        = any
  default     = []
}

#######################
# Flow Log CloudWatch #
#######################

variable "enable_flow_log_cloudwatch" {
  description = "Whether or not to enable VPC Flow Logs in CloudWatch"
  type        = bool
  default     = false
}

variable "flow_logs_cloudwatch_retention_in_days" {
  description = "The number of days to retain CloudWatch flow logs"
  type        = number
  default     = 90
}

variable "flow_logs_cloudwatch_kms_key_id" {
  description = "ID of the KMS key to use for flow logs CloudWatch encryption"
  type        = string
  default     = null
}

variable "flow_logs_cloudwatch_traffic_type" {
  description = "The type of traffic to capture. Valid values: ACCEPT, REJECT, ALL"
  type        = string
  default     = "ALL"
}

variable "flow_logs_cloudwatch_max_aggregation_interval" {
  description = "The maximum interval of time during which a flow of packets is captured and aggregated into a flow log record. Valid Values: `60` seconds or `600` seconds"
  type        = number
  default     = 600
}