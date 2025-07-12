terraform {
  backend "http" {}
  required_version = ">= 1.9.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10"
    }
  }
}

provider "kubernetes" {
}

provider "helm" {
  kubernetes = {
  }
}