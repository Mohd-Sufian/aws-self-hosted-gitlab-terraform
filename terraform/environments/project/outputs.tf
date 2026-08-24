output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_id" {
  value = module.networking.public_subnet_id
}

output "gitlab_instance_id" {
  value = module.gitlab.instance_id
}

output "gitlab_public_ip" {
  value = module.gitlab.public_ip
}

output "runner_manager_instance_id" {
  value = module.runner_manager.instance_id
}

output "runner_manager_public_ip" {
  value = module.runner_manager.public_ip
}

output "worker_asg_name" {
  value = module.runner_worker.asg_name
}

output "worker_launch_template_id" {
  value = module.runner_worker.launch_template_id
}
