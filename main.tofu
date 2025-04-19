# Root module for homelab Kubernetes infrastructure

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
  }
}

# Configure providers
provider "kubernetes" {
  config_path    = var.kube_config_path
  config_context = var.kube_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kube_config_path
    config_context = var.kube_context
  }
}

provider "kubectl" {
  config_path    = var.kube_config_path
  config_context = var.kube_context
}

provider "local" {
}

# Reference the shared module for provider configurations
module "shared" {
  source = "./shared"

  # Pass variables if needed
  kube_config_path = var.kube_config_path
  kube_context     = var.kube_context

  # Storage configuration
  local_storage_path = var.local_storage_path
  local_storage_size = var.local_storage_size
  node_hostname      = var.node_hostname

  providers = {
    kubernetes = kubernetes
    helm       = helm
    kubectl    = kubectl
    local      = local
  }
}

# Deploy main infrastructure components
module "main_infra" {
  source = "./modules/main-infra"

  # Domain configuration
  domain = var.domain

  # Component enablement
  traefik_enabled      = var.traefik_enabled
  monitoring_enabled   = var.monitoring_enabled
  kubesphere_enabled   = var.kubesphere_enabled
  digger_enabled       = var.digger_enabled
  cert_manager_enabled = var.cert_manager_enabled
  letsencrypt_enabled  = var.letsencrypt_enabled

  # Let's Encrypt configuration
  letsencrypt_email = var.letsencrypt_email

  # MetalLB configuration
  metallb_enabled   = var.metallb_enabled
  metallb_addresses = var.metallb_addresses

  # Pass through Kubernetes config
  kube_config_path = var.kube_config_path
  kube_context     = var.kube_context

  providers = {
    kubernetes = kubernetes
    helm       = helm
    kubectl    = kubectl
    local      = local
  }
}
