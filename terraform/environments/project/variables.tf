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

variable "gitlab_instance_type" {
  type    = string
  default = "t3.medium"
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
  description = "GitLab external_url. Use http://<elastic-ip> until you own a domain, then switch to https://git.yourdomain.com"
  type        = string
}

# --- Runner Manager ------------------------------------------------------

variable "runner_manager_instance_type" {
  type    = string
  default = "t3.small"
}

# --- Workers ---------------------------------------------------------

variable "worker_instance_type" {
  type    = string
  default = "t3.medium"
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
