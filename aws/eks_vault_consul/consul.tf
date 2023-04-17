data "aws_availability_zones" "available" {
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

# Note: Uncomment the below module to setup peering for connecting to a private HCP Consul cluster
# module "aws_hcp_consul" {
#   source  = "hashicorp/hcp-consul/aws"
#   version = "~> 0.12.1"
#
#   hvn                = hcp_hvn.main
#   vpc_id             = module.vpc.vpc_id
#   subnet_ids         = module.vpc.private_subnets
#   route_table_ids    = module.vpc.private_route_table_ids
#   security_group_ids = var.install_eks_cluster ? [module.eks[0].cluster_primary_security_group_id] : [""]
# }

resource "hcp_consul_cluster" "main" {
  cluster_id         = var.cluster_id
  hvn_id             = var.hvn_id
#  hvn_id             = hcp_hvn.main.hvn_id
  public_endpoint    = true
  tier               = var.consul_tier
  min_consul_version = "v1.15.2"
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.main.id
}

resource "helm_release" "consul" {
  depends_on = [kubernetes_namespace.secrets]
  name       = "${var.release_name}-consul"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  namespace  = var.namespace

  set {
    name  = "global.name"
    value = "consul"
  }

  set {
    name  = "server.replicas"
    value = var.replicas
  }

  set {
    name  = "server.bootstrapExpect"
    value = var.replicas
  }
}

resource "kubernetes_namespace" "secrets" {
  metadata {
    annotations = {
      name = var.namespace
    }

    labels = {
      purpose = "consul"
    }

    name = var.namespace
  }
}

/*
module "eks_consul_client" {
  source  = "hashicorp/hcp-consul/aws//modules/hcp-eks-client"
  version = "~> 0.12.1"

  boostrap_acl_token = hcp_consul_cluster_root_token.token.secret_id
  cluster_id         = hcp_consul_cluster.main.cluster_id
  # strip out url scheme from the public url
  consul_hosts     = tolist([substr(hcp_consul_cluster.main.consul_public_endpoint_url, 8, -1)])
  #consul_hosts     = hcp_consul_cluster.main.consul_public_endpoint_url
  consul_version   = hcp_consul_cluster.main.consul_version
  datacenter       = hcp_consul_cluster.main.datacenter
  k8s_api_endpoint = module.hcp-eks.eks_cluster_endpoint

  # The EKS node group will fail to create if the clients are
  # created at the same time. This forces the client to wait until
  # the node group is successfully created.
  depends_on = [module.hcp-eks]
}
*/