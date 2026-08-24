variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used in resource naming/tagging"
  type        = string
  default     = "gitlab-platform"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "project"
}

# --- Networking (single AZ) ------------------------------------------------

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Single AZ everything is deployed into"
  type        = string
  default     = "ap-south-1a"
}

# --- Access ------------------------------------------------------------

variable "ssh_allowed_cidr" {
  description = "Your admin IP in CIDR form, e.g. 203.0.113.4/32. Do not leave as 0.0.0.0/0."
  type        = string
}

variable "key_name" {
  description = "Optional existing EC2 key pair name for SSH access"
  type        = string
  default     = null
}

# --- GitLab server -------------------------------------------------------
# Instance types below are restricted to this AWS account's free-tier-
# eligible types: t3.micro, t3.small, c7i-flex.large, m7i-flex.large.

variable "gitlab_instance_type" {
  type    = string
  default = "c7i-flex.large" # GitLab CE wants ~4GB RAM minimum; t3.small (2GB) is too tight

  validation {
    condition     = contains(["t3.micro", "t3.small", "c7i-flex.large", "m7i-flex.large"], var.gitlab_instance_type)
    error_message = "gitlab_instance_type must be one of: t3.micro, t3.small, c7i-flex.large, m7i-flex.large."
  }
}

variable "gitlab_root_volume_size" {
  type    = number
  default = 20
}

variable "gitlab_ami" {
  description = "Optional AMI override; null uses latest Ubuntu 24.04"
  type        = string
  default     = null
}

variable "gitlab_external_url" {
  description = "Optional override, e.g. https://git.yourdomain.com. Leave unset/null and Terraform will use http://<the-elastic-ip> automatically."
  type        = string
  default     = null
}

# --- Runner Manager ------------------------------------------------------

variable "runner_manager_instance_type" {
  type    = string
  default = "t3.small"

  validation {
    condition     = contains(["t3.micro", "t3.small", "c7i-flex.large", "m7i-flex.large"], var.runner_manager_instance_type)
    error_message = "runner_manager_instance_type must be one of: t3.micro, t3.small, c7i-flex.large, m7i-flex.large."
  }
}

# --- Workers ---------------------------------------------------------

variable "worker_instance_type" {
  type    = string
  default = "t3.small" # bump to c7i-flex.large/m7i-flex.large in tfvars if CI jobs need more RAM

  validation {
    condition     = contains(["t3.micro", "t3.small", "c7i-flex.large", "m7i-flex.large"], var.worker_instance_type)
    error_message = "worker_instance_type must be one of: t3.micro, t3.small, c7i-flex.large, m7i-flex.large."
  }
}

variable "worker_root_volume_size" {
  type    = number
  default = 20
}

variable "worker_ami" {
  description = "Optional pre-baked (Packer) AMI; null bootstraps workers via scripts/worker.sh at boot"
  type        = string
  default     = null
}

variable "worker_min_size" {
  type    = number
  default = 0
}

variable "worker_max_size" {
  type    = number
  default = 3
}

variable "worker_desired_capacity" {
  type    = number
  default = 0
}
