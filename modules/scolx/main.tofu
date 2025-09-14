resource "kubernetes_namespace" "scolx" {
  metadata {
    name = "scolx"
  }
}

resource "kubernetes_secret" "scolx_registry" {
  metadata {
    name      = "scolx-registry-credentials"
    namespace = kubernetes_namespace.scolx.metadata[0].name
  }
  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (var.registry_server) = {
          username = var.registry_username
          password = var.registry_password
          auth     = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }
}

resource "kubernetes_deployment" "scolx_frontend" {
  depends_on = [kubernetes_namespace.scolx]
  metadata {
    name      = "scolx-frontend"
    namespace = kubernetes_namespace.scolx.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "scolx-frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "scolx-frontend"
        }
      }
      spec {
        image_pull_secrets {
          name = kubernetes_secret.scolx_registry.metadata[0].name
        }
        container {
          name  = "scolx-frontend"
          image = "registry.cherkaoui.ch/scolx/scolx/frontend:latest"
          env {
            name  = "BACKEND_URL"
            value = "http://scolx-backend:8080"
          }
          port {
            container_port = 3000
            name           = "main"
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "scolx" {
  depends_on = [kubernetes_namespace.scolx]
  metadata {
    name      = "scolx"
    namespace = kubernetes_namespace.scolx.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "scolx_backend" {
  depends_on = [kubernetes_namespace.scolx]
  metadata {
    name      = "scolx-backend"
    namespace = kubernetes_namespace.scolx.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "scolx-backend"
      }
    }
    template {
      metadata {
        labels = {
          app = "scolx-backend"
        }
      }
      spec {
        image_pull_secrets {
          name = kubernetes_secret.scolx_registry.metadata[0].name
        }
        container {
          name  = "scolx-backend"
          image = "registry.cherkaoui.ch/scolx/scolx/backend:latest"
          env {
            name  = "JWT_SECRET"
            value = var.jwt_secret
          }
          env {
            name  = "ADMIN_USERNAME"
            value = var.scolx_admin_user
          }
          env {
            name  = "ADMIN_PASSWORD"
            value = var.scolx_admin_password
          }
          env {
            name  = "SIGNUPS_DISABLED"
            value = true
          }
          env {
            name  = "DATABASE_PATH"
            value = "/app/data/scolx.db"
          }
          volume_mount {
            name       = "scolx"
            mount_path = "/app/data"
          }
          port {
            container_port = 8080
            name           = "main"
          }
        }
        volume {
          name = "scolx"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.scolx.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "scolx_backend" {
  metadata {
    name      = "scolx-backend"
    namespace = kubernetes_namespace.scolx.metadata[0].name
  }
  spec {
    selector = {
      app = "scolx-backend"
    }
    type = "ClusterIP"
    port {
      name        = "web"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_service" "scolx_frontend" {
  metadata {
    name      = "scolx-frontend"
    namespace = kubernetes_namespace.scolx.metadata[0].name
  }
  spec {
    selector = {
      app = "scolx-frontend"
    }
    type = "ClusterIP"
    port {
      name        = "web"
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_manifest" "scolx_frontend_ingressroute" {
  depends_on = [kubernetes_namespace.scolx]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "scolx-frontend"
      namespace = kubernetes_namespace.scolx.metadata[0].name
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
          match = "Host(`${var.scolx_hostname}`) && PathPrefix(`/`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "scolx-frontend"
              port = 3000
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