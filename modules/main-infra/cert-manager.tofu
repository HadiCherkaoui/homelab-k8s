# Cert-Manager for automated certificate management

# Deploy Cert-Manager using Helm if enabled
resource "helm_release" "cert_manager" {
  count      = var.cert_manager_enabled ? 1 : 0
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = local.cert_manager_chart_version
  namespace  = kubernetes_namespace.main_infra.metadata[0].name

  # Set default values for Cert-Manager
  values = [
    yamlencode({
      # Install CRDs
      installCRDs = true

      # Basic configuration
      replicaCount = 1 # Single replica for homelab

      # Add resource limits appropriate for homelab
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "200m"
          memory = "256Mi"
        }
      }

      # Enable webhook for validation
      webhook = {
        enabled = true
      }

      # Enable cainjector for CA injection
      cainjector = {
        enabled = true
      }

      # Enable startupapicheck to verify the installation
      startupapicheck = {
        enabled = true
      }
    }),
    yamlencode(var.cert_manager_values) # Merge with any additional values provided
  ]

  depends_on = [
    kubernetes_namespace.main_infra
  ]
}

# Create ClusterIssuer for Let's Encrypt production
resource "kubectl_manifest" "letsencrypt_prod" {
  count = var.cert_manager_enabled && var.letsencrypt_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.letsencrypt_email
        privateKeySecretRef = {
          name = "letsencrypt-prod-account-key"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "traefik"
              }
            }
          }
        ]
      }
    }
  })

  depends_on = [
    helm_release.cert_manager,
    helm_release.traefik
  ]
}
