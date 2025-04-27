provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Create monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Deploy Prometheus Operator with built-in Grafana
resource "helm_release" "monitoring" {
  depends_on = [kubernetes_namespace.monitoring]

  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          retention = "15d"
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = { storage = var.prometheus_storage }
                }
              }
            }
          }
        }
      }
      alertmanager = {
        alertmanagerSpec = {
          storage = {
            volumeClaimTemplate = {
              spec = {
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = { storage = var.alertmanager_storage }
                }
              }
            }
          }
        }
      }
      grafana = {
        enabled       = true
        adminPassword = var.grafana_admin_password
        persistence = {
          enabled = true
          size    = var.grafana_storage
        }
        ingress = {
          enabled = false
        }
        dashboards = {
          default = {
            kubernetes-cluster = {
              gnetId     = 7249
              revision   = 1
              datasource = "Prometheus"
            }
            node-exporter = {
              gnetId     = 1860
              revision   = 21
              datasource = "Prometheus"
            }
          }
        }
      }
      nodeExporter     = { enabled = true }
      kubeStateMetrics = { enabled = true }
      resources = {
        limits   = { cpu = "500m", memory = "512Mi" }
        requests = { cpu = "100m", memory = "128Mi" }
      }
    })
  ]
}

resource "kubernetes_manifest" "grafana_ingressroute" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "grafana"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
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
          match = "Host(`${var.grafana_hostname}`) && PathPrefix(`/`)"
          kind  = "Rule"

          services = [
            {
              name = "monitoring-grafana"
              port = 80
            }
          ]
        }
      ]

      tls = {
        secretName   = "grafana-tls-secret"
        certResolver = "letsencrypt"
      }
    }
  }
}