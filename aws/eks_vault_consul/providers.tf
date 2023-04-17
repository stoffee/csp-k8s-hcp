provider "helm" {
  kubernetes {
    host                   = module.hcp-eks.cluster_endpoint
    cluster_ca_certificate = module.hcp-eks.eks_cluster_certificate_authority_data
    token = module.hcp-eks.eks_cluster_token
  }
}