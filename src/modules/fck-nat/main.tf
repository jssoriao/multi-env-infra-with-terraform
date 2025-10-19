locals {
  cwagent_param_arn  = var.use_cloudwatch_agent ? var.cloudwatch_agent_configuration_param_arn != null ? var.cloudwatch_agent_configuration_param_arn : aws_ssm_parameter.cloudwatch_agent_config[0].arn : null
  cwagent_param_name = var.use_cloudwatch_agent ? var.cloudwatch_agent_configuration_param_arn != null ? split("/", data.aws_arn.ssm_param[0].resource)[1] : aws_ssm_parameter.cloudwatch_agent_config[0].name : null
}

data "aws_arn" "ssm_param" {
  count = var.use_cloudwatch_agent && var.cloudwatch_agent_configuration_param_arn != null ? 1 : 0

  arn = var.cloudwatch_agent_configuration_param_arn
}

data "aws_subnet" "selected" {
  for_each = var.instances
  id       = each.value.subnet_id
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_ami" "main" {
  count = var.ami_id != null ? 0 : 1

  most_recent = true
  owners      = ["568608671756"]

  filter {
    name   = "name"
    values = ["fck-nat-al2023-hvm-*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  count = var.use_cloudwatch_agent && var.cloudwatch_agent_configuration_param_arn == null ? 1 : 0

  name   = "${var.name}-CloudWatchAgentConfig"
  key_id = var.ssm_kms_key_id
  type   = "SecureString"
  value = templatefile("${path.module}/templates/cwagent.json", {
    METRICS_COLLECTION_INTERVAL = var.cloudwatch_agent_configuration.collection_interval,
    METRICS_NAMESPACE           = var.cloudwatch_agent_configuration.namespace
    METRICS_ENDPOINT_OVERRIDE   = var.cloudwatch_agent_configuration.endpoint_override
  })
}

module "fcknat_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name            = var.name
  use_name_prefix = true
  description     = "fck-nat instances security group"
  vpc_id          = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = data.aws_vpc.selected.cidr_block
      description = "Allow all traffic from within VPC"
    },
  ]

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all outbound IPv4 traffic"
    }
  ]

  egress_with_ipv6_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "::/0"
      description = "Allow all outbound IPv6 traffic"
    }
  ]

  tags = merge(
    { Name = var.name },
    var.tags,
    var.security_group_tags,
  )
}

resource "aws_network_interface" "main" {
  for_each = var.instances

  description       = "${var.name}-${each.key} static private ENI"
  subnet_id         = each.value.subnet_id
  security_groups   = [module.fcknat_sg.security_group_id]
  source_dest_check = false

  tags = merge(
    { Name = "${var.name}-${each.key} static private ENI" },
    var.tags,
    var.eni_tags,
  )
}

resource "aws_route" "main" {
  for_each = var.update_route_tables ? merge([
    for az, instance in var.instances : {
      for rt_idx, rt_id in instance.route_table_ids : "${az}-${rt_idx}-${rt_id}" => {
        rt_id = rt_id
        az    = az
      }
    }
  ]...) : {}

  route_table_id         = each.value.rt_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.main[each.value.az].id
}

resource "aws_eip" "main" {
  for_each = { for k, v in var.instances : k => v if v.attach_eip && v.eip == null }

  domain = "vpc"

  tags = merge(
    { Name = "${var.name}-${each.key}" },
    var.tags,
    var.eip_tags,
  )
}

resource "aws_launch_template" "main" {
  for_each = var.instances

  name_prefix   = "${var.name}-${each.key}-"
  image_id      = coalesce(var.ami_id, data.aws_ami.main[0].id)
  instance_type = var.instance_type

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.ebs_root_volume_size
      volume_type = "gp3"
      encrypted   = var.encryption
      kms_key_id  = var.ebs_kms_key_id
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.main.name
  }

  network_interfaces {
    description                 = "${var.name}-${each.key} ephemeral public ENI"
    subnet_id                   = each.value.subnet_id
    associate_public_ip_address = true
    security_groups             = concat([module.fcknat_sg.security_group_id], var.additional_security_group_ids)
  }

  dynamic "instance_market_options" {
    for_each = each.value.use_spot_instance ? [1] : []

    content {
      market_type = "spot"
      spot_options {
        max_price                      = each.value.spot_max_price
        instance_interruption_behavior = "terminate"
        spot_instance_type             = "one-time"
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      { Name = "${var.name}-${each.key}" },
      var.tags,
      var.instance_tags,
    )
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = merge(
      { Name = "${var.name}-${each.key} ephemeral public ENI" },
      var.tags,
      var.eni_tags,
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      { Name = "${var.name}-${each.key}" },
      var.tags,
      var.volume_tags,
    )
  }

  user_data = base64encode(templatefile("${path.module}/templates/user_data.sh", {
    TERRAFORM_ENI_ID                 = aws_network_interface.main[each.key].id
    TERRAFORM_EIP_ID                 = each.value.attach_eip ? coalesce(each.value.eip, aws_eip.main[each.key].id) : ""
    TERRAFORM_CWAGENT_ENABLED        = var.use_cloudwatch_agent ? "true" : ""
    TERRAFORM_CWAGENT_CFG_PARAM_NAME = local.cwagent_param_name != null ? local.cwagent_param_name : ""
  }))

  # Enforce IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = merge(
    { Name = "${var.name}-${each.key}" },
    var.tags,
  )
}

resource "aws_instance" "main" {
  for_each = var.ha_mode ? {} : var.instances

  launch_template {
    id      = aws_launch_template.main[each.key].id
    version = "$Latest"
  }

  tags = merge(
    { Name = "${var.name}-${each.key}" },
    var.tags,
    var.instance_tags,
  )

  lifecycle {
    ignore_changes = [
      source_dest_check,
      user_data,
      tags
    ]
  }
}

# resource "aws_autoscaling_group" "main" {
#   for_each = var.ha_mode ? var.instances : []

#   name_prefix         = "${var.name}-${each.key}-"
#   vpc_zone_identifier = [for k, v in var.instances : v.subnet_id]
#   desired_capacity    = length(var.instances)
#   max_size            = length(var.instances)
#   min_size            = length(var.instances)

#   mixed_instances_policy {
#     launch_template {
#       launch_template_specification {
#         launch_template_id = aws_launch_template.main[keys(var.instances)[0]].id
#         version            = "$Latest"
#       }

#       dynamic "override" {
#         for_each = { for k, v in var.instances : k => v if k != keys(var.instances)[0] }
#         content {
#           launch_template_specification {
#             launch_template_id = aws_launch_template.main[override.key].id
#             version            = "$Latest"
#           }
#           weighted_capacity = "1"
#         }
#       }
#     }

#     instances_distribution {
#       on_demand_base_capacity                  = 0
#       on_demand_percentage_above_base_capacity = 0
#       spot_allocation_strategy                 = "capacity-optimized"
#     }
#   }

#   tag {
#     key                 = "Name"
#     value               = "${local.vpc_name}/fcknat"
#     propagate_at_launch = true
#   }

#   dynamic "tag" {
#     for_each = var.tags
#     content {
#       key                 = tag.key
#       value               = tag.value
#       propagate_at_launch = true
#     }
#   }
# }

