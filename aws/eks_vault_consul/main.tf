module "hcp-eks" {
  source  = "stoffee/vault-eks/hcp"
  version = "~> 0.0.13"
  #source               = "../../../../../terraform-module-development/terraform-hcp-vault-eks/"
  cluster_id           = var.cluster_id
  deploy_hvn           = var.deploy_hvn
  hvn_id               = var.hvn_id
  hvn_region           = var.hvn_region
  deploy_vault_cluster = var.deploy_vault_cluster
  hcp_vault_cluster_id = var.hcp_vault_cluster_id
  deploy_eks_cluster   = var.deploy_eks_cluster
  vpc_region           = var.vpc_region
  #eks_instance_types   = ["t3a.medium"]
  eks_instance_types  = ["t2.small"]
  eks_cluster_version = "1.25"
}


