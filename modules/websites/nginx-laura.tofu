resource "helm_release" "nginx_laura" {
  name       = "nginx-laura"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "nginx"
  namespace  = kubernetes_namespace.websites.metadata[0].name

  values = [
    yamlencode({
      extraVolumeMounts = [
        {
          name      = "website"
          mountPath = "/app"
          subPath   = "laura"
        }
      ]
      extraVolumes = [
        {
          name = "website"
          persistentVolumeClaim = {
            claimName = kubernetes_persistent_volume_claim.websites.metadata[0].name
          }
        }
      ]
      tls = {
        enabled = false
      }
      service = {
        type = "ClusterIP"
      }
    })
  ]
}

resource "kubernetes_manifest" "laura_ingressroute" {
  depends_on = [kubernetes_namespace.websites]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "laura"
      namespace = kubernetes_namespace.websites.metadata[0].name
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
          match = "Host(`${var.laura_hostname}`) && PathPrefix(`/`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "nginx-laura"
              port = 80
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