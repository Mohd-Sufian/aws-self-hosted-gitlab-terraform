output "gitlab_sg_id" {
  value = aws_security_group.gitlab.id
}

output "runner_manager_sg_id" {
  value = aws_security_group.runner_manager.id
}

output "worker_sg_id" {
  value = aws_security_group.worker.id
}
