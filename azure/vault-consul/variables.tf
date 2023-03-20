variable "client_id" {}

variable "client_secret" {}

variable "create_resource_group" {
  type     = bool
  default  = true
  nullable = false
}

variable "key_vault_firewall_bypass_ip_cidr" {
  type    = string
  default = null
}

variable "location" {
  default = "westus2"
}

variable "managed_identity_principal_id" {
  type    = string
  default = null
}

variable "resource_group_name" {
  type    = string
  default = null
}

variable "peer_tennant_id" {
  type = string
}
variable "peer_subscription_id" {
  type = string
}