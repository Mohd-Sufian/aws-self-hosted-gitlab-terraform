variable "project_name" {
  type = string
}

variable "aws_region" {
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

variable "runner_manager_instance_type" {
  type = string
}

variable "asg_name" {
  description = "Name of the worker ASG the Fleeting plugin manages (from runner-worker module)"
  type        = string
}

variable "worker_ssh_user" {
  type    = string
  default = "ubuntu"
}

variable "key_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
