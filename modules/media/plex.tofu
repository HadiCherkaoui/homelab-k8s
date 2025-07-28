resource "kubernetes_namespace" "media" {
  metadata {
    name = var.media_namespace
  }
}

resource "helm_release" "plex" {
  depends_on = [kubernetes_namespace.media]
  name       = "plex"
  repository = "oci://tccr.io/truecharts"
  chart      = "plex"
  namespace  = kubernetes_namespace.media.metadata[0].name
  version    = "20.1.0"

  values = [
    yamlencode({
      persistence = {
        config = {
          enabled   = true
          size      = "5Gi"
          mountPath = "/config"
        }
        media = {
          enabled       = true
          existingClaim = "plex-media"
          mountPath     = "/media"
        }
      }
      plex = {
        additionalAdvertiseURL = "https://${var.plex_hostname}"
      }
      workload = {
        main = {
          podSpec = {
            containers = {
              main = {
                env = {
                  PLEX_CLAIM = var.plex_claim
                }
              }
            }
          }
        }
      }
    })
  ]
}

resource "kubernetes_persistent_volume_claim" "plex_media" {
  depends_on       = [kubernetes_namespace.media]
  wait_until_bound = false
  metadata {
    name      = "plex-media"
    namespace = kubernetes_namespace.media.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Ti"
      }
    }
  }
}

resource "kubernetes_manifest" "plex_ingressroute" {
  depends_on = [kubernetes_namespace.media]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "plex"
      namespace = kubernetes_namespace.media.metadata[0].name
      annotations = {
        "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
        "traefik.ingress.kubernetes.io/router.tls"              = "true"
        "traefik.ingress.kubernetes.io/router.tls.certresolver" = "letsencrypt"
      }
    }

    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`${var.plex_hostname}`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "plex"
              port = 32400
            }
          ]
        }
      ]

      tls = {
        certResolver = "letsencrypt"
      }
    }
  }
}