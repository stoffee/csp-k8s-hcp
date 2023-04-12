variable "vault_internal_addr" {
  type        = string
  description = "The internal url of your HCP vault cluster"
  default     = "https://MyVault.private.vault.f4cfade2-df28-47f2-a365-56gb2a62d8c5.aws.hashicorp.cloud:8200"
}


variable "vault_tier" {
  type        = string
  description = "The HCP Vault tier to use when creating a Vault cluster"
  default     = "development"
}

variable "vault_namespace" {
  default = "awscreds"
}
variable "region" {
  default = "us-west-2"
}

variable "vault_addr" {
  description = "Address of vault server to set at VAULT_ADDR"
  type        = string
}
variable "vault_token" {
  description = "Token to be used when configuring Vault"
  sensitive   = true
  default     = "bob"
}