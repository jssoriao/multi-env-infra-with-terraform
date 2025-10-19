data "aws_availability_zones" "available" {}

locals {
  vpc_name = "${var.environment}/Networking/VPC"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = local.vpc_name
  cidr = var.vpc_cidr
  azs  = local.azs

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az

  # Public subnets - /22 (1024 IPs)
  public_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 6, k)]
  public_subnet_tags = {
    "Tier" = "public"
  }
  create_multiple_public_route_tables = false
  public_route_table_tags = {
    "Tier" = "public"
  }
  public_dedicated_network_acl = true
  public_inbound_acl_rules     = concat(local.network_acls["default_inbound"], local.network_acls["public_inbound"])
  public_outbound_acl_rules    = concat(local.network_acls["default_outbound"], local.network_acls["public_outbound"])

  # Private subnets - /22 (1024 IPs)
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 6, k + 8)]
  private_subnet_tags = {
    "Tier" = "private"
  }
  private_route_table_tags = {
    "Tier" = "private"
  }
  create_private_nat_gateway_route = var.enable_nat_gateway
  private_dedicated_network_acl    = true
  private_inbound_acl_rules        = concat(local.network_acls["default_inbound"], local.network_acls["private_inbound"])
  private_outbound_acl_rules       = concat(local.network_acls["default_outbound"], local.network_acls["private_outbound"])

  # Database subnets - /23 (512 IPs)
  database_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 7, k + 32)]
  database_subnet_tags = {
    "Tier" = "database"
  }
  create_database_subnet_route_table = true
  database_route_table_tags = {
    "Tier" = "database"
  }
  create_database_nat_gateway_route = false
  create_database_subnet_group      = false
  database_dedicated_network_acl    = true
  database_inbound_acl_rules        = concat(local.network_acls["default_inbound"], local.network_acls["database_inbound"])
  database_outbound_acl_rules       = concat(local.network_acls["default_outbound"], local.network_acls["database_outbound"])

  # Intra subnets - /24 (256 IPs)
  intra_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  intra_subnet_tags = {
    "Tier" = "intra"
  }
  create_multiple_intra_route_tables = false
  intra_route_table_tags = {
    "Tier" = "intra"
  }
  intra_dedicated_network_acl = true
  intra_inbound_acl_rules     = concat(local.network_acls["default_inbound"], local.network_acls["intra_inbound"])
  intra_outbound_acl_rules    = concat(local.network_acls["default_outbound"], local.network_acls["intra_outbound"])

  # Redshift subnets - /25 (128 IPs)
  redshift_subnets = var.create_redshift_subnets ? [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 9, k + 64)] : []
  redshift_subnet_tags = {
    "Tier" = "redshift"
  }
  enable_public_redshift             = false
  create_redshift_subnet_group       = false
  create_redshift_subnet_route_table = var.create_redshift_subnets
  redshift_route_table_tags = {
    "Tier" = "redshift"
  }
  redshift_dedicated_network_acl = var.create_redshift_subnets
  redshift_inbound_acl_rules     = concat(local.network_acls["default_inbound"], local.network_acls["redshift_inbound"])
  redshift_outbound_acl_rules    = concat(local.network_acls["default_outbound"], local.network_acls["redshift_outbound"])

  # VPC Default Route Table
  manage_default_route_table = true
  default_route_table_name   = "${local.vpc_name}/default"
  default_route_table_routes = []

  # VPC Default Network ACL
  manage_default_network_acl  = true
  default_network_acl_ingress = []
  default_network_acl_egress  = []

  # VPC Default Security Group
  manage_default_security_group  = true
  default_security_group_name    = "${local.vpc_name}/default"
  default_security_group_ingress = []
  default_security_group_egress  = []

  # VPC Flow Logs
  enable_flow_log           = var.enable_flow_log_s3
  flow_log_destination_type = "s3"
  flow_log_destination_arn  = module.flow_logs_bucket.s3_bucket_arn
  flow_log_file_format      = "parquet"
  flow_log_traffic_type     = "ALL"
  vpc_flow_log_tags = {
    Name = "${local.vpc_name}/FlowLogsToS3"
  }

  vpc_tags = {}
  tags     = var.tags
}
