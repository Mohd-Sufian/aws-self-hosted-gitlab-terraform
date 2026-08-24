output "runner_manager_role_arn" {
  value = aws_iam_role.runner_manager.arn
}

output "runner_manager_instance_profile_name" {
  value = aws_iam_instance_profile.runner_manager.name
}

output "worker_role_arn" {
  value = aws_iam_role.worker.arn
}

output "worker_instance_profile_name" {
  value = aws_iam_instance_profile.worker.name
}
