# SMB server for sharing existing PVCs in homelab Kubernetes

# Deploy SMB server that can mount and share existing PVCs
resource "kubernetes_deployment" "smb_server" {
  count = var.smb_enabled ? 1 : 0

  metadata {
    name      = "smb-server"
    namespace = kubernetes_namespace.main_infra.metadata[0].name
    labels = merge(local.common_labels, {
      "app.kubernetes.io/name" = "smb-server"
    })
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "smb-server"
      }
    }

    template {
      metadata {
        labels = merge(local.common_labels, {
          "app.kubernetes.io/name" = "smb-server"
        })
      }

      spec {
        container {
          name  = "smb-server"
          image = "dperson/samba:latest"

          port {
            name           = "smb"
            container_port = 445
          }

          env {
            name  = "USER"
            value = "${var.smb_username};${var.smb_password}"
          }

          # This dynamically creates shares for each mounted PVC
          # The actual PVCs to share are mounted as volumes below
          # Each PVC will be shared with its claim name as the share name
          env {
            name  = "SHARE"
            value = join(";", [for pvc in var.smb_shared_pvcs : "${pvc};/mnt/${pvc};yes;no;no;all;${var.smb_username}"])
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          # Dynamic volume mounts for each PVC to be shared
          dynamic "volume_mount" {
            for_each = toset(var.smb_shared_pvcs)
            content {
              name       = each.key
              mount_path = "/mnt/${each.key}"
            }
          }

          security_context {
            privileged = true
          }
        }

        # Dynamic volumes for each PVC to be shared
        dynamic "volume" {
          for_each = toset(var.smb_shared_pvcs)
          content {
            name = each.key
            persistent_volume_claim {
              claim_name = each.key
            }
          }
        }
      }
    }
  }
}

# Create a service for SMB server
resource "kubernetes_service" "smb_server" {
  count = var.smb_enabled ? 1 : 0

  metadata {
    name      = "smb-server"
    namespace = kubernetes_namespace.main_infra.metadata[0].name
    labels = merge(local.common_labels, {
      "app.kubernetes.io/name" = "smb-server"
    })
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "smb-server"
    }

    port {
      name        = "smb"
      port        = 445
      target_port = 445
    }

    type = "ClusterIP"
  }
}

# Create a secret for SMB credentials
resource "kubernetes_secret" "smb_credentials" {
  count = var.smb_enabled ? 1 : 0

  metadata {
    name      = "smb-credentials"
    namespace = kubernetes_namespace.main_infra.metadata[0].name
    labels = merge(local.common_labels, {
      "app.kubernetes.io/name" = "smb-server"
    })
  }

  type = "Opaque"
  data = {
    username = base64encode(var.smb_username)
    password = base64encode(var.smb_password)
  }
}

# Create a NetworkPolicy to allow access to the SMB server
resource "kubernetes_network_policy" "smb_server" {
  count = var.smb_enabled ? 1 : 0

  metadata {
    name      = "smb-server-network-policy"
    namespace = kubernetes_namespace.main_infra.metadata[0].name
    labels = merge(local.common_labels, {
      "app.kubernetes.io/name" = "smb-server"
    })
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name" = "smb-server"
      }
    }

    ingress {
      from {
        namespace_selector {}
      }

      ports {
        port     = 445
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
