provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

resource "vault_token" "admin" {
  #role_name = "app"

  policies = ["supah-user"]

  renewable = true
  ttl = "24h"

  renew_min_lease = 43200
  renew_increment = 86400

  metadata = {
    "purpose" = "service-account"
  }
}

module "vault-namespace" {
  source  = "stoffee/vault-namespace/hashicorp"
  version = "~> 0.11.3"
  # insert the 3 required variables here
  #vault_addr                   = data.terraform_remote_state.part1.outputs.vault_public_url
  vault_addr                   = var.vault_addr
  namespace                    = var.vault_namespace
  #vault_token                  = data.terraform_remote_state.part1.outputs.vault_root_token
  #vault_token                  = var.vault_token
  vault_token                  = vault_token.admin.client_token
  create_vault_admin_policy    = true
  vault_admin_policy_name      = "supah-user"
  userpass_auth_enabled        = true
  userpass_admin = "higest_priv_user"
  userpass_admin_password = var.userpass_admin_password
  userpass_user1 = "stoffee"
  userpass_user1_password = var.userpass_user1_password
  approle_auth_enabled         = false
  aws_secret_enabled           = true
  aws_secret_engine_access_key = aws_iam_access_key.dyndns.id
  aws_secret_engine_secret_key = aws_iam_access_key.dyndns.encrypted_secret
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
    actions   = ["ec2:*"]
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