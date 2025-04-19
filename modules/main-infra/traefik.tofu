# Traefik Ingress Controller configuration

# Deploy Traefik using Helm if enabled
resource "helm_release" "traefik" {
  count      = var.traefik_enabled ? 1 : 0
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = var.traefik_chart_version
  namespace  = kubernetes_namespace.main_infra.metadata[0].name

  # Set default values for Traefik
  values = [
    yamlencode({
      # Basic configuration
      deployment = {
        replicas = 1 # Single replica for homelab
      }

      # Service configuration
      service = {
        enabled = true
        type    = "LoadBalancer" # Use LoadBalancer for homelab (works with MetalLB)
      }

      # Ports configuration
      ports = {
        web = {
          port        = 80
          expose      = true
          exposedPort = 80
          protocol    = "TCP"
          # Enable HTTP to HTTPS redirect
          redirectTo = "websecure"
        }
        websecure = {
          port        = 443
          expose      = true
          exposedPort = 443
          protocol    = "TCP"
          # Enable TLS
          tls = {
            enabled = true
          }
        }
      }

      # Dashboard and API
      ingressRoute = {
        dashboard = {
          enabled = true
        }
      }

      # Add persistent volume for TLS certificates
      persistence = {
        enabled = true
        path    = "/data"
        size    = "128Mi"
      }

      # Enable TLS and cert-manager integration
      additionalArguments = [
        "--entrypoints.websecure.http.tls=true",
        "--providers.kubernetesIngress.ingressClass=traefik",
        "--certificatesresolvers.le.acme.httpchallenge=true",
        "--certificatesresolvers.le.acme.httpchallenge.entrypoint=web",
        "--certificatesresolvers.le.acme.email=${var.letsencrypt_email}",
        "--certificatesresolvers.le.acme.storage=/data/acme.json"
      ]

      # Add resource limits
      resources = {
        requests = {
          cpu    = "100m"
          memory = "50Mi"
        }
        limits = {
          cpu    = "300m"
          memory = "150Mi"
        }
      }
    }),
    yamlencode(var.traefik_values) # Merge with any additional values provided
  ]

  depends_on = [
    kubernetes_namespace.main_infra
  ]
}

# Create IngressClass for Traefik
resource "kubernetes_ingress_class_v1" "traefik" {
  count = var.traefik_enabled ? 1 : 0

  metadata {
    name = "traefik"

    annotations = {
      "ingressclass.kubernetes.io/is-default-class" = "true"
    }
  }

  spec {
    controller = "traefik.io/ingress-controller"
  }

  depends_on = [
    helm_release.traefik
  ]
}

# Create a basic middleware for common security headers
resource "kubectl_manifest" "middleware_security_headers" {
  count = var.traefik_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "security-headers"
      namespace = kubernetes_namespace.main_infra.metadata[0].name
    }
    spec = {
      headers = {
        browserXssFilter     = true
        contentTypeNosniff   = true
        forceSTSHeader       = true
        frameDeny            = true
        stsIncludeSubdomains = true
        stsPreload           = true
        stsSeconds           = 31536000
        customRequestHeaders = {
          X-Forwarded-Proto = "https"
        }
      }
    }
  })

  depends_on = [
    helm_release.traefik
  ]
}