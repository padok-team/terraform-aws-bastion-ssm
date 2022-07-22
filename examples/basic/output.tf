output "ssm_logging_bucket_id" {
  description = "SSM logging bucket"
  value       = module.my_ssm_bastion.ssm_logging_bucket_id
}

output "security_group_id" {
  description = "Bastion security group"
  value       = module.my_ssm_bastion.security_group_id
}
