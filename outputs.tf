output "ssm_private_key" {
  value       = var.manage_ssm_user_ssh_key ? tls_private_key.ssm_user[0].private_key_pem : ""
  description = "ssm ssh private key for tunnel"
  sensitive   = true
}
