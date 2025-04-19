# Main infrastructure module for homelab Kubernetes

# Reference the shared module for provider configurations
module "shared" {
  source = "../../shared"
}

# Local variables for configuration
locals {
  namespace = "ns-main-infra"

  # Common labels to apply to all resources
  common_labels = {
    "app.kubernetes.io/managed-by" = "opentofu"
    "app.kubernetes.io/part-of"    = "homelab-k8s"
    "environment"                  = "homelab"
  }
}

# Create namespace for all main infrastructure components
resource "kubernetes_namespace" "main_infra" {
  metadata {
    name = local.namespace

    labels = merge(local.common_labels, {
      "app.kubernetes.io/name" = "main-infra"
    })
  }
}

# Create a TLS secret for the default certificate
resource "kubernetes_secret" "default_tls" {
  count = var.traefik_enabled && var.cert_manager_enabled && var.letsencrypt_enabled ? 0 : 1

  metadata {
    name      = "default-tls"
    namespace = kubernetes_namespace.main_infra.metadata[0].name
  }

  type = "kubernetes.io/tls"

  # This is a self-signed placeholder certificate
  # It will be replaced by Let's Encrypt certificates when they are issued
  data = {
    "tls.crt" = file("${path.module}/certs/placeholder.crt")
    "tls.key" = file("${path.module}/certs/placeholder.key")
  }
}
