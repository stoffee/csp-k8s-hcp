provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}
resource "vault_policy" "admin_policy" {
  namespace = "admin"
  name      = "supah-user"
  policy    = <<EOT
  # Manage auth methods broadly across Vault
path "auth/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, and delete auth methods
path "sys/auth/*"
{
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth"
{
  capabilities = ["read"]
}

# Create and manage ACL policies
path "sys/policies/acl/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List ACL policies
path "sys/policies/acl"
{
  capabilities = ["list"]
}

# Create and manage secrets engines broadly across Vault.
path "sys/mounts/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List enabled secrets engines
path "sys/mounts"
{
  capabilities = ["read", "list"]
}

# List, create, update, and delete key/value secrets at secret/
path "secret/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Manage transit secrets engine
path "transit/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Read health checks
path "sys/health"
{
  capabilities = ["read", "sudo"]
}
EOT
}

resource "vault_token_auth_backend_role" "admin" {
  role_name              = "supah-user"
  allowed_policies       = ["supah-user"]
  orphan                 = true
  token_period           = "86400"
  renewable              = true
  token_explicit_max_ttl = "115200"
}

resource "vault_token" "admin" {
  role_name = "supah-user"

  policies = ["supah-user"]

  renewable = true
  ttl       = "24h"

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
  vault_addr = var.vault_addr
  namespace  = var.vault_namespace
  #vault_token                  = data.terraform_remote_state.part1.outputs.vault_root_token
  vault_token = var.vault_token
  #vault_token                  = vault_token.admin.client_token
  create_vault_admin_policy    = true
  vault_admin_policy_name      = "supah-user"
  userpass_auth_enabled        = false
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
  namespace  = var.vault_namespace
  depends_on = [module.vault-namespace]
  name       = "dyndns"
  policy     = <<EOT
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