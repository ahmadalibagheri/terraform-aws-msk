terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.71"
    }
  }
}

provider "aws" {
  region = data.terraform_remote_state.infra.outputs.aws_region
}

data "aws_eks_cluster" "eks" {
  name = var.eks_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.eks_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token
}
