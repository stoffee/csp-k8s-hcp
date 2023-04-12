output "token" {
  description = "The admin token"
  value       = vault_token.admin.client_token
}