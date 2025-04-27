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
          enabled = false
        }
      }

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

      persistence = {
        enabled = true
        path    = "/data"
      }

      securityContext = {
        runAsNonRoot = false
        runAsUser    = 0
        capabilities = {
          drop = ["ALL"]
          add  = ["NET_BIND_SERVICE"]
        }
      }

      ports = {
        web = {
          port        = 80
          exposedPort = 80
        }
        websecure = {
          port        = 443
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
        metrics = {
          port        = 8080
          exposedPort = 8080
        }
      }

      hostNetwork = true

      additionalArguments = [
        "--entrypoints.web.http.redirections.entryPoint.to=websecure",
        "--entrypoints.web.http.redirections.entryPoint.scheme=https"
      ]
    })
  ]

  depends_on = [
    kubernetes_namespace.traefik,
    helm_release.local_path_provisioner
  ]
}