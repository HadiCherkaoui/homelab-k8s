# Digger configuration for OpenTofu GitOps

# Deploy Digger using Helm if enabled
resource "helm_release" "digger" {
  count      = var.digger_enabled ? 1 : 0
  name       = "digger"
  repository = "https://diggerhq.github.io/digger"
  chart      = "digger"
  version    = var.digger_chart_version
  namespace  = kubernetes_namespace.main_infra.metadata[0].name

  # Set default values for Digger
  values = [
    yamlencode({
      # Basic configuration
      replicaCount = 1 # Single replica for homelab

      # Image configuration
      image = {
        repository = "diggerhq/digger"
        pullPolicy = "IfNotPresent"
      }

      # Service configuration
      service = {
        type = "ClusterIP"
        port = 80
      }

      # Ingress configuration
      ingress = {
        enabled   = var.traefik_enabled
        className = "traefik"
        annotations = {
          "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
        }
        hosts = [
          {
            host = "digger.${var.domain}"
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
              }
            ]
          }
        ]
        tls = [
          {
            hosts      = ["digger.${var.domain}"]
            secretName = "digger-tls"
          }
        ]
      }

      # Resource limits
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

      # Persistence for state
      persistence = {
        enabled = true
        size    = "1Gi"
      }

      # Configure Digger to use OpenTofu instead of Terraform
      config = {
        # Specify OpenTofu as the IaC tool
        defaultIaCTool = "opentofu"

        # Set OpenTofu binary path and version
        opentofu = {
          binaryPath = "/usr/local/bin/tofu"
          version    = "1.9.0" # Match your OpenTofu version
        }

        # GitHub configuration - these should be set via secrets
        # in a production environment
        github = {
          appId         = ""
          privateKey    = ""
          webhookSecret = ""
        }
      }
    }),
    yamlencode(var.digger_values) # Merge with any additional values provided
  ]

  depends_on = [
    kubernetes_namespace.main_infra,
    helm_release.traefik
  ]
}
