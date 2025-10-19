data "aws_ami" "latest" {
  most_recent = true

  filter {
    name = "name"
    values = [
      "twingate/images/hvm-ssd/twingate-*",
    ]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  owners = ["617935088040"]
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  name            = var.name
  use_name_prefix = true
  description     = "Twingate connector security group"
  vpc_id          = var.vpc_id

  egress_with_cidr_blocks = [
    {
      rule        = "all-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all outbound TCP traffic"
    },
    {
      rule        = "all-udp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all outbound UDP traffic"
    },
    {
      rule        = "all-icmp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all outbound IPv4 ICMP traffic"
    },
  ]

  tags = merge(
    { Name = var.name },
    var.tags
  )
}

resource "aws_network_interface" "this" {
  for_each = var.instances

  description     = "${var.name}-${each.key} ENI"
  subnet_id       = each.value.subnet_id
  security_groups = concat([module.security_group.security_group_id], var.additional_security_groups)

  tags = merge(
    { Name = "${var.name}-${each.key}" },
    var.tags,
  )
}

module "twingate_connector_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.1.1"

  for_each = var.instances

  name                        = "${var.name}-${each.key}"
  ignore_ami_changes          = true
  user_data_replace_on_change = true

  ami           = data.aws_ami.latest.id
  instance_type = each.value.instance_type

  root_block_device = {
    encrypted  = true
    kms_key_id = var.ebs_kms_key_id
  }

  network_interface = {
    0 = {
      network_interface_id  = aws_network_interface.this[each.key].id
      delete_on_termination = false
    }
  }

  create_spot_instance = each.value.use_spot_instance
  spot_price           = each.value.spot_max_price
  spot_type            = each.value.spot_type

  iam_instance_profile = aws_iam_instance_profile.this.name

  user_data = templatefile("${path.module}/templates/user_data.sh", {
    TWINGATE_NETWORK       = each.value.network
    TWINGATE_ACCESS_TOKEN  = each.value.connector_access_token
    TWINGATE_REFRESH_TOKEN = each.value.connector_refresh_token
  })

  tags = merge(
    { Name = "${var.name}-${each.key}" },
    var.tags,
  )
}
