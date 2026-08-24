# ---------------------------------------------------------------------------
# IAM: two separate least-privilege roles.
#   - Runner Manager role: what the AWS Fleeting plugin needs to scale the
#     worker Auto Scaling Group.
#   - Worker role: empty by default. Add permissions here only when a CI
#     job actually needs them (e.g. S3 access for artifacts).
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# --- Runner Manager -------------------------------------------------------

resource "aws_iam_role" "runner_manager" {
  name               = "${var.project_name}-runner-manager-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "runner_manager" {
  # List/describe-style ASG calls are account-wide - they don't target a
  # single ASG, so a resource-tag condition can't be evaluated against them
  # and would just cause a silent deny. These stay unconditioned.
  statement {
    sid    = "FleetingAutoScalingDescribe"
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
    ]
    resources = ["*"]
  }

  # These DO target one named ASG and support resource-level permissions,
  # so we can scope them to just the tagged worker ASG.
  statement {
    sid    = "FleetingAutoScalingControl"
    effect = "Allow"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Component"
      values   = ["runner-worker"]
    }
  }

  statement {
    sid    = "DescribeWorkerInstances"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeTags",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "TagWorkerInstances"
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
    ]
    resources = ["arn:aws:ec2:*:*:instance/*"]
  }

  # Required by fleeting-plugin-aws's default use_static_credentials = false:
  # it connects to each new worker by pushing a temporary key via EC2
  # Instance Connect, not a static keypair. Scoped by the tag AWS itself
  # applies to every instance an ASG launches.
  statement {
    sid    = "FleetingInstanceConnect"
    effect = "Allow"
    actions = [
      "ec2-instance-connect:SendSSHPublicKey",
    ]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/aws:autoscaling:groupName"
      values   = ["${var.project_name}-workers"]
    }
  }
}

resource "aws_iam_policy" "runner_manager" {
  name   = "${var.project_name}-runner-manager-policy"
  policy = data.aws_iam_policy_document.runner_manager.json
}

resource "aws_iam_role_policy_attachment" "runner_manager" {
  role       = aws_iam_role.runner_manager.name
  policy_arn = aws_iam_policy.runner_manager.arn
}

resource "aws_iam_instance_profile" "runner_manager" {
  name = "${var.project_name}-runner-manager-profile"
  role = aws_iam_role.runner_manager.name
}

# --- Worker -----------------------------------------------------------
# Intentionally minimal. Attach additional aws_iam_role_policy resources
# here as CI jobs need real permissions (e.g. S3 read/write for artifacts).

resource "aws_iam_role" "worker" {
  name               = "${var.project_name}-worker-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = var.tags
}

resource "aws_iam_instance_profile" "worker" {
  name = "${var.project_name}-worker-profile"
  role = aws_iam_role.worker.name
}
