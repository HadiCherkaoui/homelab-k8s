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

resource "kubernetes_deployment" "quillium_webhook" {
  depends_on = [kubernetes_persistent_volume_claim.websites]

  metadata {
    name      = "quillium-webhook"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        app = "quillium-webhook"
      }
    }
    template {
      metadata {
        labels = {
          app = "quillium-webhook"
        }
      }
      spec {
        container {
          name  = "quillium-webhook"
          image = "ghcr.io/linuxserver-labs/webhook:latest"
          port {
            container_port = 9000
          }
          volume_mount {
            name       = "website"
            mount_path = "/docs"
            sub_path   = "quillium-docs"
          }
          volume_mount {
            name       = "hook"
            mount_path = "/config/hooks/hooks.json"
            sub_path   = "hooks.json"
          }
          volume_mount {
            name       = "script"
            mount_path = "/pull_git.sh"
            sub_path   = "pull_git.sh"
          }
          env {
            name  = "PUID"
            value = "0"
          }
          env {
            name  = "PGID"
            value = "0"
          }
          env {
            name  = "TZ"
            value = "Europe/Zurich"
          }
        }
        volume {
          name = "website"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.websites.metadata[0].name
          }
        }
        volume {
          name = "hook"
          secret {
            secret_name = "webhook-config"
            items {
              key  = "hooks.json"
              path = "hooks.json"
            }
          }
        }
        volume {
          name = "script"
          config_map {
            name = "webhook-scripts"
            items {
              key  = "pull_git.sh"
              path = "pull_git.sh"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_secret" "webhook_config" {
  metadata {
    name      = "webhook-config"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }

  data = {
    "hooks.json" = file("${path.module}/../../.extra/hooks.json")
  }
}

resource "kubernetes_config_map" "webhook_scripts" {
  metadata {
    name      = "webhook-scripts"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }

  data = {
    "pull_git.sh" = file("${path.module}/../../.extra/pull_git.sh")
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

resource "kubernetes_service" "quillium_webhook" {
  depends_on = [kubernetes_deployment.quillium_webhook]

  metadata {
    name      = "quillium-webhook"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }

  spec {
    selector = {
      app = "quillium-webhook"
    }
    type = "ClusterIP"
    port {
      port        = 9000
      target_port = 9000
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

resource "kubernetes_manifest" "quillium_webhook_ingressroute" {
  depends_on = [kubernetes_namespace.websites]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "quillium-webhook"
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
          match = "Host(`${var.quillium_webhook_hostname}`) && PathPrefix(`/`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "quillium-webhook"
              port = 9000
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