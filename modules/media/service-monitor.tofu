resource "kubernetes_manifest" "media_servicemonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "media-services"
      namespace = "monitoring"
      labels = {
        app                      = "kube-prometheus-stack-media"
        "app.kubernetes.io/name" = "media-services"
        release                  = "monitoring"
      }
    }
    spec = {
      jobLabel = "app.kubernetes.io/name"
      selector = {
        matchExpressions = [
          {
            key      = "app.kubernetes.io/name"
            operator = "In"
            values   = ["prowlarr", "radarr", "sonarr"]
          }
        ]
      }
      namespaceSelector = {
        matchNames = [var.media_namespace]
      }
      endpoints = [
        {
          port            = "metrics"
          path            = "/metrics"
          interval        = "30s"
          honorLabels     = true
          honorTimestamps = true
          relabelings = [
            {
              action       = "replace"
              sourceLabels = ["__metrics_path__"]
              targetLabel  = "metrics_path"
            }
          ]
        }
      ]
    }
  }
}