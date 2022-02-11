output "ssm_private_key" {
  description = "ssm ssh private key for tunnel"
  value       = var.manage_ssm_user_ssh_key ? tls_private_key.ssm_user[0].private_key_pem : ""
  sensitive   = true
}
