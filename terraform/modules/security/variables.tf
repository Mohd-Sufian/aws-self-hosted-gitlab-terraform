variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH into GitLab/Runner Manager, e.g. 203.0.113.4/32"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
