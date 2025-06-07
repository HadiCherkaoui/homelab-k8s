resource "kubernetes_deployment" "quillium_docs" {
  depends_on = [kubernetes_persistent_volume_claim.websites]

  metadata {
    name      = "quillium-docs"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        app = "quillium-docs"
      }
    }
    template {
      metadata {
        labels = {
          app = "quillium-docs"
        }
      }
      spec {
        container {
          name  = "quillium-docs"
          image = "squidfunk/mkdocs-material:latest"
          port {
            container_port = 8000
          }
          volume_mount {
            name       = "website"
            mount_path = "/docs"
            sub_path   = "quillium-docs"
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

resource "kubernetes_service" "quillium_docs" {
  depends_on = [kubernetes_deployment.quillium_docs]

  metadata {
    name      = "quillium-docs"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }

  spec {
    selector = {
      app = "quillium-docs"
    }
    type = "ClusterIP"
    port {
      port        = 8000
      target_port = 8000
    }
  }
}

resource "kubernetes_manifest" "quillium_docs_ingressroute" {
  depends_on = [kubernetes_namespace.websites]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "quillium-docs"
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
          match = "Host(`${var.quillium_docs_hostname}`) && PathPrefix(`/`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "quillium-docs"
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