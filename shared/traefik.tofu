resource "kubernetes_namespace" "traefik" {
  metadata {
    name = var.traefik_namespace
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  namespace  = kubernetes_namespace.traefik.metadata[0].name

  # Use values block for complex configurations
  values = [
    yamlencode({
      # Use CRD provider (default)
      providers = {
        kubernetesCRD = {
          enabled = true
        }
        kubernetesIngress = {
          enabled = false # Disable legacy Ingress provider
        }
      }

      # Create IngressClass and set as default
      ingressClass = {
        enabled        = true
        isDefaultClass = true
      }
      ingressRoute = {
        dashboard = {
          enabled = true
          annotations = {
            "kubernetes.io/ingress.class" = "traefik"
          }
        }
      }

      # Configure ACME (Let's Encrypt)
      certificatesResolvers = {
        letsencrypt = {
          acme = {
            email   = var.acme_email
            storage = "/data/acme.json"
            httpChallenge = {
              entryPoint = "web"
            }
          }
        }
      }

      # Enable persistence for ACME storage
      persistence = {
        enabled = true
        path    = "/data"
      }

      # Ensure web entrypoint is available for HTTP-01 challenge
      ports = {
        web = {
          port        = 8000
          exposedPort = 80
        }
        websecure = {
          port        = 8443
          exposedPort = 443
          tls = {
            enabled = true
          }
        }
        traefik = {
          port        = 9000
          exposedPort = 9000
          expose = {
            default = true
          }
        }
      }

      hostNetwork = true

      # Configure service exposure
      service = {
        enabled = false
        type    = "LoadBalancer"
        ports = {
          web = {
            targetPort = 8000
            port       = 80
          }
          websecure = {
            targetPort = 8443
            port       = 443
          }
          traefik = {
            targetPort = 9000
            port       = 9000
          }
        }
      }

      # Explicitly define exposing ports through annotations instead of expose field
      additionalArguments = [
        "--entrypoints.web.http.redirections.entryPoint.to=websecure",
        "--entrypoints.web.http.redirections.entryPoint.scheme=https"
      ]
    })
  ]

  depends_on = [
    kubernetes_namespace.traefik,
    helm_release.local_path_provisioner,
    helm_release.metallb
  ]
}