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
  statement {
    sid    = "FleetingAutoScalingControl"
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
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
