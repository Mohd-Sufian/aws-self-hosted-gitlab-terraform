output "instance_id" {
  value = aws_instance.runner_manager.id
}

output "public_ip" {
  value = aws_instance.runner_manager.public_ip
}
