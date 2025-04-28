resource "kubernetes_namespace" "traefik" {
  metadata {
    name = var.traefik_namespace
  }
}

resource "kubernetes_manifest" "traefik_security_headers" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"

    metadata = {
      name      = "security-headers"
      namespace = kubernetes_namespace.traefik.metadata[0].name
    }

    spec = {
      headers = {
        browserXssFilter        = true
        contentTypeNosniff      = true
        stsSeconds              = 63072000
        stsIncludeSubdomains    = true
        stsPreload              = true
        customFrameOptionsValue = "SAMEORIGIN"
        referrerPolicy          = "no-referrer-when-downgrade"
        contentSecurityPolicy   = "default-src 'self' https:; script-src 'self' https: 'unsafe-inline'; style-src 'self' https: 'unsafe-inline'; img-src 'self' data:; font-src 'self' data:; connect-src 'self' https:; object-src 'none'; base-uri 'self'; frame-ancestors 'self';"
        permissionsPolicy       = "geolocation=(), microphone=(), camera=(), fullscreen=()"
      }
    }
  }
}



resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  namespace  = kubernetes_namespace.traefik.metadata[0].name
  wait       = false

  values = [
    yamlencode({
      providers = {
        kubernetesCRD = {
          enabled             = true
          allowCrossNamespace = true
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