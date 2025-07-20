resource "kubernetes_namespace" "openwebui" {
  metadata {
    name = "openwebui"
  }
}

resource "kubernetes_deployment" "openwebui" {
  depends_on = [kubernetes_persistent_volume_claim.openwebui]

  metadata {
    name      = "openwebui"
    namespace = kubernetes_namespace.openwebui.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        app = "openwebui"
      }
    }
    template {
      metadata {
        labels = {
          app = "openwebui"
        }
      }
      spec {
        container {
          name  = "openwebui"
          image = "ghcr.io/open-webui/open-webui:main"
          port {
            container_port = 8080
            name           = "http"
          }
          volume_mount {
            name       = "openwebui"
            mount_path = "/app/backend/data"
          }
          env {
            name = "ENABLE_OAUTH_SIGNUP"
            value = true
          }
          env {
            name = "GOOGLE_CLIENT_ID"
            value = var.google_client_id
          }
          env {
            name = "GOOGLE_CLIENT_SECRET"
            value = var.google_client_secret
          }
          env {
            name = "GITHUB_CLIENT_ID"
            value = var.github_client_id
          }
          env {
            name = "GITHUB_CLIENT_SECRET"
            value = var.github_client_secret
          }
          env {
            name = "MICROSOFT_CLIENT_ID"
            value = var.microsoft_client_id
          }
          env {
            name = "MICROSOFT_CLIENT_SECRET"
            value = var.microsoft_client_secret
          }
          env {
            name = "MICROSOFT_TENANT_ID"
            value = var.microsoft_tenant_id
          }
        }
        volume {
          name = "openwebui"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.openwebui.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "openwebui" {
  metadata {
    name      = "openwebui"
    namespace = kubernetes_namespace.openwebui.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_service" "openwebui" {
  depends_on = [kubernetes_deployment.openwebui]

  metadata {
    name      = "openwebui"
    namespace = kubernetes_namespace.openwebui.metadata[0].name
  }

  spec {
    selector = {
      app = "openwebui"
    }
    type = "ClusterIP"
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_manifest" "openwebui_ingressroute" {
  depends_on = [kubernetes_namespace.openwebui]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "openwebui"
      namespace = kubernetes_namespace.openwebui.metadata[0].name
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
          match = "Host(`${var.openwebui_hostname}`) && PathPrefix(`/`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "open-webui"
              port = "http"
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