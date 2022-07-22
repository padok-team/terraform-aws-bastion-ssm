output "ssm_logging_bucket" {
  description = "SSM logging bucket"
  value       = module.my_ssm_bastion.ssm_logging_bucket
}
