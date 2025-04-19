# Monitoring stack configuration (Prometheus, Grafana, etc.)

# Deploy kube-prometheus-stack using Helm if enabled
resource "helm_release" "prometheus_stack" {
  count      = var.monitoring_enabled ? 1 : 0
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_chart_version
  namespace  = kubernetes_namespace.main_infra.metadata[0].name

  # Set default values for Prometheus stack
  values = [
    yamlencode({
      # Global settings
      global = {
        evaluation_interval = "1m"
        scrape_interval     = "30s"
      }

      # Prometheus configuration
      prometheus = {
        enabled                                 = true
        serviceMonitorSelectorNilUsesHelmValues = false
        serviceMonitorSelector                  = {}
        serviceMonitorNamespaceSelector         = {}
        prometheusSpec = {
          retention = "7d" # Data retention period
          resources = {
            requests = {
              memory = "256Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "200m"
            }
          }
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "10Gi"
                  }
                }
              }
            }
          }
        }
      }

      # Grafana configuration
      grafana = {
        enabled       = true
        adminPassword = "admin" # Default password, should be changed after first login
        persistence = {
          enabled = true
          size    = "2Gi"
        }
        resources = {
          requests = {
            memory = "128Mi"
            cpu    = "100m"
          }
          limits = {
            memory = "256Mi"
            cpu    = "200m"
          }
        }
        # Add default dashboards
        dashboardProviders = {
          "dashboardproviders.yaml" = {
            apiVersion = 1
            providers = [
              {
                name            = "default"
                orgId           = 1
                folder          = ""
                type            = "file"
                disableDeletion = false
                editable        = true
                options = {
                  path = "/var/lib/grafana/dashboards/default"
                }
              }
            ]
          }
        }
        # Configure ingress for Grafana
        ingress = {
          enabled          = true
          ingressClassName = "traefik"
          hosts            = ["grafana.${var.domain}"]
          path             = "/"
          annotations = {
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
          }
          tls = [
            {
              hosts      = ["grafana.${var.domain}"]
              secretName = "grafana-tls"
            }
          ]
        }
      }

      # AlertManager configuration
      alertmanager = {
        enabled = true
        alertmanagerSpec = {
          storage = {
            volumeClaimTemplate = {
              spec = {
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "1Gi"
                  }
                }
              }
            }
          }
        }
      }

      # Node exporter for host metrics
      nodeExporter = {
        enabled = true
      }

      # kube-state-metrics for Kubernetes object metrics
      kubeStateMetrics = {
        enabled = true
      }
    }),
    yamlencode(var.monitoring_values) # Merge with any additional values provided
  ]

  depends_on = [
    kubernetes_namespace.main_infra,
    helm_release.traefik
  ]
}

# Create ServiceMonitor for Traefik if both Traefik and monitoring are enabled
resource "kubectl_manifest" "traefik_service_monitor" {
  count = var.traefik_enabled && var.monitoring_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "traefik"
      namespace = kubernetes_namespace.main_infra.metadata[0].name
      labels = {
        "app.kubernetes.io/name" = "traefik"
        "release"                = "prometheus"
      }
    }
    spec = {
      endpoints = [
        {
          port     = "metrics"
          path     = "/metrics"
          interval = "30s"
        }
      ]
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "traefik"
        }
      }
    }
  })

  depends_on = [
    helm_release.prometheus_stack,
    helm_release.traefik
  ]
}