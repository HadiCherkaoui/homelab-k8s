# Kube-VIP LoadBalancer with DHCP support
# Alternative to MetalLB that works better with home networks

# Create namespace for kube-vip
resource "kubernetes_namespace" "kube_vip" {
  metadata {
    name = "kube-vip"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

# ServiceAccount for kube-vip
resource "kubernetes_service_account" "kube_vip" {
  metadata {
    name      = "kube-vip"
    namespace = kubernetes_namespace.kube_vip.metadata[0].name
  }
}

# ClusterRole for kube-vip
resource "kubernetes_cluster_role" "kube_vip" {
  metadata {
    name = "system:kube-vip-role"
  }

  rule {
    api_groups = [""]
    resources  = ["services", "services/status", "nodes", "endpoints"]
    verbs      = ["list", "get", "watch", "update"]
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["list", "get", "watch", "update", "create"]
  }
}

# ClusterRoleBinding for kube-vip
resource "kubernetes_cluster_role_binding" "kube_vip" {
  metadata {
    name = "system:kube-vip-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kube_vip.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kube_vip.metadata[0].name
    namespace = kubernetes_namespace.kube_vip.metadata[0].name
  }
}

# DaemonSet for kube-vip
resource "kubernetes_daemonset" "kube_vip" {
  metadata {
    name      = "kube-vip-ds"
    namespace = kubernetes_namespace.kube_vip.metadata[0].name
    labels = {
      app = "kube-vip-ds"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "kube-vip-ds"
      }
    }

    template {
      metadata {
        labels = {
          app = "kube-vip-ds"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.kube_vip.metadata[0].name
        host_network         = true
        toleration {
          effect   = "NoSchedule"
          operator = "Exists"
        }
        toleration {
          effect   = "NoExecute"
          operator = "Exists"
        }

        container {
          name    = "kube-vip"
          image   = "ghcr.io/kube-vip/kube-vip:v0.9.2"
          command = ["/kube-vip"]
          args    = ["manager"]

          env {
            name  = "vip_arp"
            value = "true"
          }
          env {
            name  = "vip_interface"
            value = "enp6s18"
          }
          env {
            name  = "svc_enable"
            value = "true"
          }
          env {
            name  = "svc_election"
            value = "true"
          }
          # Enable DHCP support for services
          env {
            name  = "enableServicesElection"
            value = "true"
          }

          security_context {
            capabilities {
              add = ["NET_ADMIN", "NET_RAW"]
            }
          }

          volume_mount {
            mount_path = "/etc/kubernetes/admin.conf"
            name       = "kubeconfig"
            read_only  = true
          }
        }

        volume {
          name = "kubeconfig"
          host_path {
            path = "/etc/kubernetes/admin.conf"
          }
        }

        node_selector = {
          "node-role.kubernetes.io/control-plane" = ""
        }
      }
    }
  }
}
