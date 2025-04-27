terraform {
  required_version = ">= 1.9.0"
  required_providers {
    kubernetes = {
      source  = "registry.opentofu.org/hashicorp/kubernetes"
      version = ">= 2.20"
    }
    helm = {
      source  = "registry.opentofu.org/hashicorp/helm"
      version = ">= 2.10"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}