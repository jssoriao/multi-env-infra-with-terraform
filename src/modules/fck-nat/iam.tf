resource "aws_iam_instance_profile" "main" {
  name_prefix = "${var.name}-"
  role        = aws_iam_role.main.name

  tags = merge(
    { Name = var.name },
    var.tags,
    var.instance_role_tags,
  )
}

resource "aws_iam_role" "main" {
  name_prefix = "${var.name}-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    { Name = var.name },
    var.tags,
    var.instance_role_tags,
  )
}

data "aws_iam_policy_document" "main" {
  statement {
    sid    = "ManageNetworkInterface"
    effect = "Allow"
    actions = [
      "ec2:AttachNetworkInterface",
      "ec2:ModifyNetworkInterfaceAttribute",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "ManageEIPAllocation"
    effect = "Allow"
    actions = [
      "ec2:AssociateAddress",
      "ec2:DisassociateAddress",
    ]
    resources = [
      "*"
    ]
  }

  dynamic "statement" {
    for_each = var.use_cloudwatch_agent ? ["x"] : []

    content {
      sid    = "CWAgentSSMParameter"
      effect = "Allow"
      actions = [
        "ssm:GetParameter"
      ]
      resources = [
        local.cwagent_param_arn
      ]
    }
  }

  dynamic "statement" {
    for_each = var.use_cloudwatch_agent ? ["x"] : []

    content {
      sid    = "CWAgentMetrics"
      effect = "Allow"
      actions = [
        "cloudwatch:PutMetricData"
      ]
      resources = [
        "*"
      ]
      condition {
        test     = "StringEquals"
        variable = "cloudwatch:namespace"
        values   = [var.cloudwatch_agent_configuration.namespace]
      }
    }
  }

  dynamic "statement" {
    for_each = var.additional_role_policy_statements
    content {
      sid       = statement.value.sid
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "additional_policies" {
  count      = length(var.additional_role_policy_arns)
  role       = aws_iam_role.main.name
  policy_arn = var.additional_role_policy_arns[count.index]
}

resource "aws_iam_role_policy" "main" {
  name_prefix = "DefaultPolicy-"
  role        = aws_iam_role.main.id
  policy      = data.aws_iam_policy_document.main.json
}
