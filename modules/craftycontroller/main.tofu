resource "kubernetes_namespace" "craftycontroller" {
  metadata {
    name = "craftycontroller"
  }
}

resource "kubernetes_deployment" "craftycontroller" {
  depends_on = [kubernetes_persistent_volume_claim.craftycontroller]

  metadata {
    name      = "craftycontroller"
    namespace = kubernetes_namespace.craftycontroller.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        app = "craftycontroller"
      }
    }
    template {
      metadata {
        labels = {
          app = "craftycontroller"
        }
      }
      spec {
        container {
          name  = "craftycontroller"
          image = "registry.gitlab.com/crafty-controller/crafty-4:latest"
          port {
            container_port = 8443
            name           = "https"
          }
          port {
            container_port = 25565
            name           = "mc-srv-1"
          }
          port {
            container_port = 8123
            name           = "dynmap"
          }
          volume_mount {
            name       = "crafty"
            mount_path = "/crafty/app/config"
            sub_path   = "config"
          }
          volume_mount {
            name       = "import"
            mount_path = "/crafty/import"
          }
          volume_mount {
            name       = "crafty"
            mount_path = "/crafty/servers"
            sub_path   = "servers"
          }
          volume_mount {
            name       = "crafty"
            mount_path = "/crafty/logs"
            sub_path   = "logs"
          }
          volume_mount {
            name       = "crafty"
            mount_path = "/crafty/backups"
            sub_path   = "backups"
          }
        }
        volume {
          name = "crafty"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.craftycontroller.metadata[0].name
          }
        }
        volume {
          name = "import"
          empty_dir {
            medium = "Memory"
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "craftycontroller" {
  metadata {
    name      = "craftycontroller"
    namespace = kubernetes_namespace.craftycontroller.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_service" "craftycontroller" {
  depends_on = [kubernetes_deployment.craftycontroller]

  metadata {
    name      = "craftycontroller"
    namespace = kubernetes_namespace.craftycontroller.metadata[0].name
  }

  spec {
    selector = {
      app = "craftycontroller"
    }
    type = "ClusterIP"
    port {
      name        = "web"
      port        = 8443
      target_port = 8443
      protocol    = "TCP"
    }
    port {
      name        = "minecraft"
      port        = 25565
      target_port = 25565
      protocol    = "TCP"
    }
    port {
      name        = "dynmap"
      port        = 8123
      target_port = 8123
      protocol    = "TCP"
    }
  }
}