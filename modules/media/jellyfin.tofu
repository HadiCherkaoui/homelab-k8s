resource "helm_release" "jellyfin" {
  depends_on = [kubernetes_namespace.media]
  name       = "jellyfin"
  repository = "https://jellyfin.github.io/jellyfin-helm"
  chart      = "jellyfin"
  version    = "2.3.0"
  namespace  = kubernetes_namespace.media.metadata[0].name

  values = [
    yamlencode({
      persistence = {
        config = {
          enabled = true
          size    = "5Gi"
        }
        media = {
          enabled       = true
          existingClaim = "plex-media"
          mountPath     = "/media"
        }
      }
      metrics = {
        enabled = true
      }
    })
  ]
}

resource "kubernetes_manifest" "jellyfin_ingressroute" {
  depends_on = [kubernetes_namespace.media]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "jellyfin"
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
          match = "Host(`${var.jellyfin_hostname}`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "jellyfin"
              port = 8096
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