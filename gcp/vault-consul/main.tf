# Provider Configuration
provider "google" {
  project = "my-project-id"
  region  = "us-central1"
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
  region         = "us-central1"
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

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "15.1.0"

  name               = "hcp-gke"
  location           = "us-central1-a"
  network            = module.hcp.network_name
  subnetwork         = module.hcp.consul_subnet_name
  ip_range_pods      = "10.4.0.0/14"
  ip_range_services  = "10.0.0.0/20"
  node_pool_defaults = {
    machine_type = "n1-standard-2"
    disk_size_gb = 50
    disk_type    = "pd-standard"
    autoscaling  = {
      min_node_count = 1
      max_node_count = 3
    }
  }
}

# Outputs
output "vault_address" {
  value = module.vault.public_address
}

output "consul_address" {
  value = module.consul.public_address
}

output "gke_cluster_endpoint" {
  value = module.gke.endpoint
}

output "gke_cluster_ca_certificate" {
  value = module.gke.ca_certificate
}
