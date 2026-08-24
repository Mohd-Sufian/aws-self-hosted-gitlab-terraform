variable "project_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "gitlab_instance_type" {
  type = string
}

variable "gitlab_root_volume_size" {
  type = number
}

variable "gitlab_ami" {
  description = "Optional AMI override; defaults to latest Ubuntu 24.04 when null/empty"
  type        = string
  default     = null
}

variable "gitlab_external_url" {
  description = "Optional override, e.g. https://git.yourdomain.com. Leave null to auto-derive http://<elastic-ip>."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Optional EC2 key pair name for SSH; leave null to rely on SSM only"
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
