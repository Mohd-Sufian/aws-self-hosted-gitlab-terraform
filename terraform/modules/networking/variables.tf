variable "project_name" {
  description = "Project name used in resource naming/tagging"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the single public subnet"
  type        = string
}

variable "availability_zone" {
  description = "Single AZ everything is deployed into"
  type        = string
}

variable "tags" {
  description = "Common tags applied to every resource"
  type        = map(string)
  default     = {}
}
