# ---------------------------------------------------------------------------
# GitLab Server EC2 + EIP + data EBS volume
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

resource "aws_eip" "gitlab" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-gitlab-eip"
  })
}

locals {
  # Use a real domain if one was supplied; otherwise fall back to the EIP
  # we just allocated. Either way this is known BEFORE the instance boots,
  # so external_url is correct from the very first cloud-init run - no
  # second apply needed.
  gitlab_external_url = coalesce(var.gitlab_external_url, "http://${aws_eip.gitlab.public_ip}")
}

resource "aws_instance" "gitlab" {
  ami                         = coalesce(var.gitlab_ami, data.aws_ami.ubuntu.id)
  instance_type               = var.gitlab_instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  root_block_device {
    volume_size = var.gitlab_root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/../../../scripts/gitlab-server.sh", {
    gitlab_external_url = local.gitlab_external_url
  })

  tags = merge(var.tags, {
    Name      = "${var.project_name}-gitlab"
    Component = "gitlab"
  })
}

resource "aws_eip_association" "gitlab" {
  instance_id   = aws_instance.gitlab.id
  allocation_id = aws_eip.gitlab.id
}
