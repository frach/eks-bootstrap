provider "aws" {
  region              = var.region
  allowed_account_ids = [var.account_id]
}

terraform {
  required_version = "= 1.2.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.6.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "= 1.14.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket  = "eks-bootstrap-tf-backend-bucket"
    key     = "state.tfstate"
    region  = "eu-west-1"
    encrypt = false
  }
}
