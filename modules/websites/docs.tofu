resource "kubernetes_deployment" "docs" {
  depends_on = [kubernetes_persistent_volume_claim.websites]

  metadata {
    name      = "docs"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        app = "docs"
      }
    }
    template {
      metadata {
        labels = {
          app = "docs"
        }
      }
      spec {
        container {
          name  = "docs"
          image = "squidfunk/mkdocs-material:latest"
          port {
            container_port = 8000
          }
          volume_mount {
            name       = "website"
            mount_path = "/docs"
            sub_path   = "docs"
          }
        }
        volume {
          name = "website"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.websites.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "docs" {
  depends_on = [kubernetes_deployment.docs]

  metadata {
    name      = "docs"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }

  spec {
    selector = {
      app = "docs"
    }
    type = "ClusterIP"
    port {
      port        = 8000
      target_port = 8000
    }
  }
}

resource "kubernetes_manifest" "docs_ingressroute" {
  depends_on = [kubernetes_namespace.websites]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "docs"
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
          match = "Host(`${var.docs_hostname}`) && PathPrefix(`/`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "docs"
              port = 8000
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