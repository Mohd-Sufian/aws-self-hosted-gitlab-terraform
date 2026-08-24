variable "project_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "worker_instance_type" {
  type = string
}

variable "worker_root_volume_size" {
  type = number
}

variable "worker_ami" {
  description = "Optional pre-baked (e.g. Packer) AMI; null bootstraps via scripts/worker.sh at boot instead"
  type        = string
  default     = null
}

variable "asg_name" {
  type = string
}

variable "worker_min_size" {
  type = number
}

variable "worker_max_size" {
  type = number
}

variable "worker_desired_capacity" {
  type = number
}

variable "key_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
