# ---------------------------------------------------------------------------
# Runner Manager EC2
# ---------------------------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "runner_manager" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type                = var.runner_manager_instance_type
  subnet_id                    = var.subnet_id
  vpc_security_group_ids       = [var.security_group_id]
  associate_public_ip_address  = true
  iam_instance_profile         = var.instance_profile_name
  key_name                     = var.key_name

  user_data = templatefile("${path.module}/../../../scripts/runner-manager.sh", {
    aws_region      = var.aws_region
    asg_name        = var.asg_name
    worker_ssh_user = var.worker_ssh_user
  })

  tags = merge(var.tags, {
    Name      = "${var.project_name}-runner-manager"
    Component = "runner-manager"
  })
}
