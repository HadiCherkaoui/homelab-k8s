resource "kubernetes_manifest" "prowlarr_servicemonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "prowlarr"
      namespace = "monitoring"
      labels = {
        release = "kube-prometheus-stack"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/instance" = "prowlarr"
          "app.kubernetes.io/name"     = "prowlarr"
        }
      }
      namespaceSelector = {
        matchNames = [var.media_namespace]
      }
      endpoints = [
        {
          port     = "metrics"
          path     = "/metrics"
          interval = "30s"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "radarr_servicemonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "radarr"
      namespace = "monitoring"
      labels = {
        release = "kube-prometheus-stack"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/instance" = "radarr"
          "app.kubernetes.io/name"     = "radarr"
        }
      }
      namespaceSelector = {
        matchNames = [var.media_namespace]
      }
      endpoints = [
        {
          port     = "metrics"
          path     = "/metrics"
          interval = "30s"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "sonarr_servicemonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "sonarr"
      namespace = "monitoring"
      labels = {
        release = "kube-prometheus-stack"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/instance" = "sonarr"
          "app.kubernetes.io/name"     = "sonarr"
        }
      }
      namespaceSelector = {
        matchNames = [var.media_namespace]
      }
      endpoints = [
        {
          port     = "metrics"
          path     = "/metrics"
          interval = "30s"
        }
      ]
    }
  }
}