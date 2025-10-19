data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  flow_logs_bucket_name               = var.enable_flow_log_s3 ? lower("${var.environment}-Networking-VPCFlowLogs-${random_pet.this[0].id}") : ""
  flow_logs_cloudwatch_log_group_name = var.enable_flow_log_cloudwatch ? "${var.environment}-Networking-VPCFlowLogs" : ""
  flow_log_group_arns = [
    for log_group in aws_cloudwatch_log_group.flow_log :
    "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:${log_group.name}:*"
  ]
}

resource "random_pet" "this" {
  count = var.enable_flow_log_s3 ? 1 : 0

  length = 2
}

data "aws_iam_policy_document" "flow_log_s3" {
  count = var.enable_flow_log_s3 ? 1 : 0

  statement {
    sid = "AWSLogDeliveryWrite"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${local.flow_logs_bucket_name}/AWSLogs/*"]
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${local.flow_logs_bucket_name}"]
  }
}

module "flow_logs_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.4.0"

  create_bucket = var.enable_flow_log_s3

  bucket = local.flow_logs_bucket_name

  versioning = {
    enabled    = true
    mfa_delete = false
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.flow_logs_s3_kms_key_id
        sse_algorithm     = "aws:kms"
      }
      bucket_key_enabled = true
    }
  }

  policy                                = var.enable_flow_log_s3 ? data.aws_iam_policy_document.flow_log_s3[0].json : ""
  attach_policy                         = true
  attach_deny_insecure_transport_policy = true

  force_destroy = true

  lifecycle_rule = var.flow_logs_bucket_lifecycle_rule

  tags = merge({
    Name = "${local.vpc_name}/FlowLogsBucket"
  }, var.tags)
}

#######################
# Flow Log CloudWatch #
#######################

resource "aws_flow_log" "cloudwatch" {
  count = var.enable_flow_log_cloudwatch ? 1 : 0

  log_destination_type     = "cloud-watch-logs"
  log_destination          = try(aws_cloudwatch_log_group.flow_log[0].arn, null)
  iam_role_arn             = try(aws_iam_role.vpc_flow_log_cloudwatch[0].arn, null)
  traffic_type             = var.flow_logs_cloudwatch_traffic_type
  vpc_id                   = module.vpc.vpc_id
  max_aggregation_interval = var.flow_logs_cloudwatch_max_aggregation_interval
  tags = merge({
    Name = local.flow_logs_cloudwatch_log_group_name
  }, var.tags)
}

resource "aws_cloudwatch_log_group" "flow_log" {
  count = var.enable_flow_log_cloudwatch ? 1 : 0

  name_prefix       = "${local.flow_logs_cloudwatch_log_group_name}-"
  retention_in_days = var.flow_logs_cloudwatch_retention_in_days
  kms_key_id        = var.flow_logs_cloudwatch_kms_key_id
  skip_destroy      = false
  log_group_class   = "INFREQUENT_ACCESS"

  tags = merge({
    Name = local.flow_logs_cloudwatch_log_group_name
  }, var.tags)
}

resource "aws_iam_role" "vpc_flow_log_cloudwatch" {
  count = var.enable_flow_log_cloudwatch ? 1 : 0

  name_prefix        = "${local.flow_logs_cloudwatch_log_group_name}-"
  assume_role_policy = data.aws_iam_policy_document.flow_log_cloudwatch_assume_role[0].json
  tags = merge({
    Name = local.flow_logs_cloudwatch_log_group_name
  }, var.tags)
}

data "aws_iam_policy_document" "flow_log_cloudwatch_assume_role" {
  count = var.enable_flow_log_cloudwatch ? 1 : 0

  statement {
    sid = "AWSVPCFlowLogsAssumeRole"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "vpc_flow_log_cloudwatch" {
  count = var.enable_flow_log_cloudwatch ? 1 : 0

  role       = aws_iam_role.vpc_flow_log_cloudwatch[0].name
  policy_arn = aws_iam_policy.vpc_flow_log_cloudwatch[0].arn
}

resource "aws_iam_policy" "vpc_flow_log_cloudwatch" {
  count = var.enable_flow_log_cloudwatch ? 1 : 0

  name_prefix = "${local.flow_logs_cloudwatch_log_group_name}-"
  policy      = data.aws_iam_policy_document.vpc_flow_log_cloudwatch[0].json
  tags = merge({
    Name = local.flow_logs_cloudwatch_log_group_name
  }, var.tags)
}

data "aws_iam_policy_document" "vpc_flow_log_cloudwatch" {
  count = var.enable_flow_log_cloudwatch ? 1 : 0

  statement {
    sid    = "AWSVPCFlowLogsPushToCloudWatch"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = local.flow_log_group_arns
  }
}
