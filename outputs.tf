# Output
output "ssm_logging_bucket_id" {
  description = "SSM logging bucket"
  value       = module.ssm_logging_bucket[0].id
}

output "security_group_id" {
  description = "Bastion security group"
  value       = aws_security_group.ssm_sg.id
}
