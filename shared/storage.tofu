# Local Path Provisioner for homelab Kubernetes cluster
# Uses Rancher's Local Path Provisioner for dynamic PVC provisioning

# Create namespace for the local-path-provisioner
resource "kubernetes_namespace" "local_path_storage" {
  metadata {
    name = var.local_path_provisioner_namespace
    labels = {
      "app.kubernetes.io/managed-by" = "opentofu"
      "app.kubernetes.io/part-of"    = "homelab-k8s"
    }
  }
}

# ConfigMap for local-path-provisioner configuration
resource "kubernetes_config_map" "local_path_config" {
  metadata {
    name      = "local-path-config"
    namespace = kubernetes_namespace.local_path_storage.metadata[0].name
  }

  data = {
    "config.json" = jsonencode({
      nodePathMap = [
        {
          node  = "DEFAULT_PATH_FOR_NON_LISTED_NODES"
          paths = [var.local_storage_path]
        },
        # Add specific node configurations if needed
        # {
        #   node  = var.node_hostname
        #   paths = [var.local_storage_path]
        # }
      ]
    })

    "setup" = <<-EOT
      #!/bin/sh
      set -eu
      mkdir -m 0777 -p "$VOL_DIR"
    EOT

    "teardown" = <<-EOT
      #!/bin/sh
      set -eu
      rm -rf "$VOL_DIR"
    EOT

    "helperPod.yaml" = <<-EOT
      apiVersion: v1
      kind: Pod
      metadata:
        name: helper-pod
      spec:
        priorityClassName: system-node-critical
        tolerations:
          - key: node.kubernetes.io/disk-pressure
            operator: Exists
            effect: NoSchedule
        containers:
        - name: helper-pod
          image: busybox
    EOT
  }
}

# ServiceAccount for local-path-provisioner
resource "kubernetes_service_account" "local_path_provisioner_service_account" {
  metadata {
    name      = "local-path-provisioner-service-account"
    namespace = kubernetes_namespace.local_path_storage.metadata[0].name
  }
}

# ClusterRole for local-path-provisioner
resource "kubernetes_cluster_role" "local_path_provisioner_role" {
  metadata {
    name = "local-path-provisioner-role"
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "persistentvolumeclaims", "configmaps", "pods", "events"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumes"]
    verbs      = ["*"]
  }
}

# ClusterRoleBinding for local-path-provisioner
resource "kubernetes_cluster_role_binding" "local_path_provisioner_bind" {
  metadata {
    name = "local-path-provisioner-bind"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.local_path_provisioner_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.local_path_provisioner_service_account.metadata[0].name
    namespace = kubernetes_namespace.local_path_storage.metadata[0].name
  }
}

# Deployment for local-path-provisioner
resource "kubernetes_deployment" "local_path_provisioner" {
  metadata {
    name      = "local-path-provisioner"
    namespace = kubernetes_namespace.local_path_storage.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "local-path-provisioner"
      }
    }

    template {
      metadata {
        labels = {
          app = "local-path-provisioner"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.local_path_provisioner_service_account.metadata[0].name
        container {
          name  = "local-path-provisioner"
          image = "rancher/local-path-provisioner:v0.0.31"

          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/etc/config/"
          }
        }

        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map.local_path_config.metadata[0].name
          }
        }
      }
    }
  }
}

# StorageClass for local-path-provisioner
resource "kubernetes_storage_class" "local_path" {
  metadata {
    name = "local-path"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "rancher.io/local-path"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}
