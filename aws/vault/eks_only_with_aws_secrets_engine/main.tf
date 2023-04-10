module "hcp-eks" {
  source  = "stoffee/vault-eks/hcp"
  version = "~> 0.0.13"
  #source               = "/Users/stoffee/git/terraform-module-development/terraform-hcp-vault-eks"
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

module "vault-namespace" {
  source  = "stoffee/vault-namespace/hashicorp"
  version = "~> 0.11.2"
  # insert the 3 required variables here
  vault_addr                   = module.hcp-eks.vault_public_url
  namespace                    = var.vault_namespace
  vault_token                  = module.hcp-eks.vault_root_token
  create_vault_admin_policy    = true
  vault_admin_policy_name      = "supah-user"
  userpass_auth_enabled        = false
  approle_auth_enabled         = false
  aws_secret_enabled           = true
  aws_secret_engine_access_key = aws_iam_access_key.dyndns.id
  aws_secret_engine_secret_key = aws_iam_access_key.dyndns.encrypted_secret
  depends_on = [module.hcp-eks]
}

resource "aws_iam_access_key" "dyndns" {
  user = aws_iam_user.dyndns.name
  #  pgp_key = "keybase:some_person_that_exists"
}

resource "aws_iam_user" "dyndns" {
  name = "dyndns"
  path = "/system/"
}

data "aws_iam_policy_document" "dyndns" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "dyndns" {
  name   = "test"
  user   = aws_iam_user.dyndns.name
  policy = data.aws_iam_policy_document.dyndns.json
}

resource "vault_policy" "dyndns" {
  namespace = var.vault_namespace
  depends_on = [module.vault-namespace]
  name   = "dyndns"
  policy = <<EOT
path "aws/creds/dyndns" {
  capabilities = [ "create", "update", "delete", "list", "read" ]
}
path "auth/token/create" {
  capabilities = [ "create", "update", "delete", "list", "read" ]
}
EOT
}

resource "vault_aws_secret_backend_role" "aws-iam-creds" {
  backend         = "aws"
  depends_on      = [module.vault-namespace]
  name            = "dyndns"
  credential_type = "iam_user"
  namespace       = var.vault_namespace

  policy_document = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "iam:GetUser",
      "Resource": [
        "arn:aws:iam::347318413499:user/vault*"
      ]
    }
  ]
}
EOT
}