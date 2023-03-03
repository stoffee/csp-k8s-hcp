#auto
provider "azurerm" {
  features {}
}

# Variables
variable "hcp_token" {}
variable "vault_admin_password" {}
variable "vault_license" {}

# Modules
module "hcp" {
  source  = "hashicorp/hcp/hcp"
  version = "1.1.0"

  access_token   = var.hcp_token
  region         = "eastus"
  hvn_name       = "hcp-hvn"
  network_cidr   = "10.1.0.0/16"
  gateway_subnet = "10.1.1.0/24"
  vault_subnet   = "10.1.2.0/24"
  consul_subnet  = "10.1.3.0/24"
}

module "vault" {
  source  = "hashicorp/hcp/vault"
  version = "1.0.0"

  hvn_id         = module.hcp.hvn_id
  admin_password = var.vault_admin_password
  license        = var.vault_license
}

module "consul" {
  source  = "hashicorp/hcp/consul"
  version = "1.0.0"

  hvn_id = module.hcp.hvn_id
}

module "aks" {
  source  = "terraform-azurerm-modules/kubernetes-engine/azurerm"
  version = "2.2.1"

  resource_group_name  = "hcp-rg"
  location             = "eastus"
  network_profile_name = "hcp-np"
  dns_prefix           = "hcp-aks"
  kubernetes_version   = "1.20.7"
  linux_profile        = {
    admin_username = "azureuser"
  }
  node_pools = [
    {
      name            = "hcp-nodepool"
      vm_size         = "Standard_D2_v2"
      availability_zones = [1,2]
      node_count      = 3
      vnet_subnet_id  = module.hcp.consul_subnet_id
    }
  ]
}

# Outputs
output "vault_address" {
  value = module.vault.public_address
}

output "consul_address" {
  value = module.consul.public_address
}

output "aks_cluster_endpoint" {
  value = module.aks.kube_config.0.host
}

output "aks_cluster_ca_certificate" {
  value = module.aks.kube_config.0.cluster_ca_certificate
}
