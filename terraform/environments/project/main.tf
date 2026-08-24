terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "networking" {
  source = "../../modules/networking"

  project_name        = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  availability_zone    = var.availability_zone
  tags                 = local.common_tags
}

module "security" {
  source = "../../modules/security"

  project_name     = var.project_name
  vpc_id           = module.networking.vpc_id
  ssh_allowed_cidr = var.ssh_allowed_cidr
  tags             = local.common_tags
}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  tags         = local.common_tags
}

module "gitlab" {
  source = "../../modules/gitlab"

  project_name             = var.project_name
  subnet_id                = module.networking.public_subnet_id
  security_group_id        = module.security.gitlab_sg_id
  gitlab_instance_type     = var.gitlab_instance_type
  gitlab_root_volume_size  = var.gitlab_root_volume_size
  gitlab_ami               = var.gitlab_ami
  gitlab_external_url      = var.gitlab_external_url
  key_name                 = var.key_name
  tags                     = local.common_tags
}

module "runner_worker" {
  source = "../../modules/runner-worker"

  project_name             = var.project_name
  subnet_id                = module.networking.public_subnet_id
  security_group_id        = module.security.worker_sg_id
  instance_profile_name    = module.iam.worker_instance_profile_name
  worker_instance_type     = var.worker_instance_type
  worker_root_volume_size  = var.worker_root_volume_size
  worker_ami               = var.worker_ami
  asg_name                 = "${var.project_name}-workers"
  worker_min_size          = var.worker_min_size
  worker_max_size          = var.worker_max_size
  worker_desired_capacity  = var.worker_desired_capacity
  key_name                 = var.key_name
  tags                     = local.common_tags
}

module "runner_manager" {
  source = "../../modules/runner-manager"

  project_name                   = var.project_name
  aws_region                     = var.aws_region
  subnet_id                      = module.networking.public_subnet_id
  security_group_id              = module.security.runner_manager_sg_id
  instance_profile_name          = module.iam.runner_manager_instance_profile_name
  runner_manager_instance_type   = var.runner_manager_instance_type
  asg_name                       = module.runner_worker.asg_name
  key_name                       = var.key_name
  tags                            = local.common_tags
}
