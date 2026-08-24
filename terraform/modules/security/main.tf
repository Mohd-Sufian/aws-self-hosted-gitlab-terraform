# ---------------------------------------------------------------------------
# Security groups: GitLab server, Runner Manager, Worker
# Split into three groups instead of one shared SG, per design.
# ---------------------------------------------------------------------------

resource "aws_security_group" "gitlab" {
  name        = "${var.project_name}-gitlab-sg"
  description = "GitLab server: HTTP/HTTPS/SSH"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH (admin + GitLab SSH clone) - restrict to your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-gitlab-sg" })
}

resource "aws_security_group" "runner_manager" {
  name        = "${var.project_name}-runner-manager-sg"
  description = "Runner Manager: SSH from admin, outbound to GitLab/AWS API/workers"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH - restrict to your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-runner-manager-sg" })
}

resource "aws_security_group" "worker" {
  name        = "${var.project_name}-worker-sg"
  description = "CI worker: SSH only from Runner Manager, outbound to internet"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Runner Manager only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.runner_manager.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-worker-sg" })
}
