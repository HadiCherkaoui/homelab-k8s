resource "kubernetes_namespace" "websites" {
  metadata {
    name = "websites"
  }
}

resource "helm_release" "nginx_hadi" {
  name       = "nginx-hadi"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "nginx"
  namespace  = kubernetes_namespace.websites.metadata[0].name
  wait       = false

  values = [
    yamlencode({
      extraVolumeMounts = [
        {
          name      = "website"
          mountPath = "/app"
          subPath   = "hadi"
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

resource "kubernetes_persistent_volume_claim" "websites" {
  metadata {
    name      = "websites"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_manifest" "hadi_ingressroute" {
  depends_on = [kubernetes_namespace.websites]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "hadi"
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
          match = "Host(`${var.hadi_hostname}`) && PathPrefix(`/`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "nginx-hadi"
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