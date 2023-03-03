# auto
provider "aws" {
  region = "us-west-2"
}

# Variables
variable "hcp_token" {}
variable "eks_cluster_name" {}
variable "vault_admin_password" {}
variable "vault_license" {}

# VPC
resource "aws_vpc" "hcp_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "hcp-vpc"
  }
}

# Subnets
resource "aws_subnet" "hcp_subnet_1" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.hcp_vpc.id
  availability_zone = "us-west-2a"
  tags = {
    Name = "hcp-subnet-1"
  }
}

resource "aws_subnet" "hcp_subnet_2" {
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.hcp_vpc.id
  availability_zone = "us-west-2b"
  tags = {
    Name = "hcp-subnet-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "hcp_igw" {
  vpc_id = aws_vpc.hcp_vpc.id
  tags = {
    Name = "hcp-igw"
  }
}

# Route Table
resource "aws_route_table" "hcp_rt" {
  vpc_id = aws_vpc.hcp_vpc.id
  tags = {
    Name = "hcp-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "hcp_rta_1" {
  subnet_id = aws_subnet.hcp_subnet_1.id
  route_table_id = aws_route_table.hcp_rt.id
}

resource "aws_route_table_association" "hcp_rta_2" {
  subnet_id = aws_subnet.hcp_subnet_2.id
  route_table_id = aws_route_table.hcp_rt.id
}

# Security Group
resource "aws_security_group" "hcp_sg" {
  name_prefix = "hcp-sg"
  vpc_id = aws_vpc.hcp_vpc.id
}

# HCP HVN
resource "hcp_network" "hvn" {
  name = "hcp-hvn"
  aws_region = "us-west-2"
  network_cidr = "10.1.0.0/16"
  gateway_subnet_id = aws_subnet.hcp_subnet_1.id
  vault_subnet_id = aws_subnet.hcp_subnet_2.id
  security_group_ids = [aws_security_group.hcp_sg.id]
  access_token = var.hcp_token
}

# Vault
resource "hcp_vault" "vault" {
  hvn_id = hcp_network.hvn.id
  admin_password = var.vault_admin_password
  license = var.vault_license
}

# Consul
resource "hcp_consul" "consul" {
  hvn_id = hcp_network.hvn.id
}

# EKS Cluster
resource "aws_eks_cluster" "hcp_eks" {
  name = var.eks_cluster_name
  role_arn = hcp_network.hvn.iam_role_arn
  vpc_config {
    subnet_ids = [aws_subnet.hcp_subnet_1.id, aws_subnet.hcp_subnet_2.id]
security_group_ids = [aws_security_group.hcp_sg.id]
}
}

output "vault_address" {
value = hcp_vault.vault.public_address
}

output "consul_address" {
value = hcp_consul.consul.public_address
}

output "eks_cluster_endpoint" {
value = aws_eks_cluster.hcp_eks.endpoint
}

output "eks_cluster_certificate_authority_data" {
value = aws_eks_cluster.hcp_eks.certificate_authority_data
}