# ---------------------------------------------------------------------------
# Worker Launch Template + Auto Scaling Group
# Single AZ - matches the rest of this environment. The ASG's desired
# capacity is driven by the Runner Manager's Fleeting plugin, not by
# Terraform (min=0, desired=0 by default; jobs scale it up on demand).
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

resource "aws_launch_template" "worker" {
  name_prefix   = "${var.project_name}-worker-"
  image_id      = coalesce(var.worker_ami, data.aws_ami.ubuntu.id)
  instance_type = var.worker_instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups              = [var.security_group_id]
    subnet_id                    = var.subnet_id
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.worker_root_volume_size
      volume_type = "gp3"
      encrypted   = true
    }
  }

  # Only needed when var.worker_ami is null, i.e. we're bootstrapping the
  # worker at boot instead of using a pre-baked Packer image.
  user_data = var.worker_ami == null ? base64encode(file("${path.module}/../../../scripts/worker.sh")) : null

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name      = "${var.project_name}-worker"
      Component = "runner-worker"
    })
  }

  tags = var.tags
}

resource "aws_autoscaling_group" "worker" {
  name                      = var.asg_name
  vpc_zone_identifier       = [var.subnet_id]
  min_size                  = var.worker_min_size
  max_size                  = var.worker_max_size
  desired_capacity          = var.worker_desired_capacity

  # Per fleeting-plugin-aws's own setup requirements: it manages scale-in
  # itself (via autoscaling:TerminateInstanceInAutoScalingGroup), so this
  # ASG shouldn't have its own opinions about it.
  protect_from_scale_in     = true
  suspended_processes       = ["AZRebalance"]

  launch_template {
    id      = aws_launch_template.worker.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(var.tags, { Component = "runner-worker" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
