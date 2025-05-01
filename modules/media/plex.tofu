resource "kubernetes_namespace" "media" {
  metadata {
    name = var.media_namespace
  }
}

resource "helm_release" "plex" {
  depends_on = [kubernetes_namespace.media]
  name       = "plex"
  repository = "https://raw.githubusercontent.com/plexinc/pms-docker/gh-pages"
  chart      = "plex-media-server"
  namespace  = kubernetes_namespace.media.metadata[0].name

  values = [
    yamlencode({
      extraVolumeMounts = [
        {
          name      = "media"
          mountPath = "/media"
        }
      ]
      extraVolumes = [
        {
          name = "media"
          persistentVolumeClaim = {
            claimName = "plex-media"
          }
        }
      ]
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
          match = "Host(`${var.plex_hostname}`) && PathPrefix(`/`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "plex-plex-media-server"
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