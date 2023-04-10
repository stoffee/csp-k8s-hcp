terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cdunlap"

    workspaces {
      name = "terraform-hcp-vault-eks-aws-creds-part2"
    }
  }
}

data "terraform_remote_state" "part1" {
  backend = "remote"

  config = {
    organization = "cdunlap"

    workspaces = {
      name = "terraform-hcp-vault-eks-aws-creds-part1"
    }
  }
}