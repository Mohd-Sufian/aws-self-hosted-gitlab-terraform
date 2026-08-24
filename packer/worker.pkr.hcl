# ---------------------------------------------------------------------------
# Placeholder for a future Packer build of the worker AMI.
#
# Not wired up yet: modules/runner-worker currently bootstraps workers at
# boot via scripts/worker.sh instead (var.worker_ami defaults to null).
# Once this is built out, set worker_ami in terraform.tfvars to the
# resulting AMI ID to skip the boot-time install and speed up worker
# start times.
# ---------------------------------------------------------------------------

# packer {
#   required_plugins {
#     amazon = {
#       version = ">= 1.2.0"
#       source  = "github.com/hashicorp/amazon"
#     }
#   }
# }
#
# source "amazon-ebs" "worker" {
#   ami_name      = "gitlab-worker-ubuntu-2404-{{timestamp}}"
#   instance_type = "t3.medium"
#   region        = "ap-south-1"
#   source_ami_filter {
#     filters = {
#       name                = "ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-amd64-server-*"
#       virtualization-type = "hvm"
#       root-device-type    = "ebs"
#     }
#     owners      = ["099720109477"]
#     most_recent = true
#   }
#   ssh_username = "ubuntu"
# }
#
# build {
#   sources = ["source.amazon-ebs.worker"]
#   provisioner "shell" {
#     script = "../scripts/worker.sh"
#   }
# }
