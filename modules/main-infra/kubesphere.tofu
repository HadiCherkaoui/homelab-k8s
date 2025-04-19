# KubeSphere dashboard configuration

# Deploy KubeSphere using kubectl manifests if enabled
resource "kubectl_manifest" "kubesphere_installer" {
  count     = var.kubesphere_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "installer.kubesphere.io/v1alpha1"
    kind       = "ClusterConfiguration"
    metadata = {
      name      = "ks-installer"
      namespace = kubernetes_namespace.main_infra.metadata[0].name
      labels = {
        "app.kubernetes.io/name"    = "ks-installer"
        "app.kubernetes.io/version" = var.kubesphere_version
      }
    }
    spec = {
      persistence = {
        storageClass = "" # Use default storage class
      }
      authentication = {
        jwtSecret = "" # Auto-generated if empty
      }
      etcd = {
        monitoring  = false       # Disable etcd monitoring for homelab
        endpointIps = "localhost" # Use built-in etcd
      }
      common = {
        redis = {
          enabled = true
        }
        openldap = {
          enabled = false # Disable LDAP for homelab
        }
        minioVolumeSize = "2Gi"
        monitoring = {
          # Use existing Prometheus if monitoring is enabled
          endpoint      = var.monitoring_enabled ? "http://prometheus-operated.${kubernetes_namespace.main_infra.metadata[0].name}.svc:9090" : ""
          GPUMonitoring = false
        }
        es = { # Elasticsearch settings
          elasticsearchMasterVolumeSize = "2Gi"
          elasticsearchDataVolumeSize   = "4Gi"
          logMaxAge                     = 7 # Log retention in days
          elkPrefix                     = "logstash"
        }
      }
      # Enable minimal components for homelab
      alerting = {
        enabled = false
      }
      auditing = {
        enabled = false
      }
      devops = {
        enabled = false
      }
      events = {
        enabled = false
      }
      logging = {
        enabled = false
      }
      metrics_server = {
        enabled = true
      }
      monitoring = {
        # Disable built-in monitoring if we're using our own Prometheus
        enabled = !var.monitoring_enabled
      }
      multicluster = {
        clusterRole = "none" # Single cluster for homelab
      }
      networkpolicy = {
        enabled = false
      }
      notification = {
        enabled = false
      }
      openpitrix = {
        enabled = true # Enable app store
      }
      servicemesh = {
        enabled = false
      }
    }
  })

  depends_on = [
    kubernetes_namespace.main_infra,
    helm_release.prometheus_stack
  ]
}

# Create Ingress for KubeSphere console if both KubeSphere and Traefik are enabled
resource "kubernetes_ingress_v1" "kubesphere_console" {
  count = var.kubesphere_enabled && var.traefik_enabled ? 1 : 0

  metadata {
    name      = "kubesphere-console"
    namespace = "kubesphere-system" # KubeSphere creates its own namespace

    annotations = {
      # Ingress class and middleware
      "kubernetes.io/ingress.class"                      = "traefik"
      "traefik.ingress.kubernetes.io/router.middlewares" = "${kubernetes_namespace.main_infra.metadata[0].name}-security-headers@kubernetescrd"

      # Cert-manager annotations for automatic TLS certificate
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    # TLS configuration for secure access
    tls {
      hosts       = ["kubesphere.${var.domain}"]
      secret_name = "kubesphere-tls"
    }

    rule {
      host = "kubesphere.${var.domain}"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "ks-console"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubectl_manifest.kubesphere_installer,
    helm_release.traefik,
    kubectl_manifest.letsencrypt_prod
  ]
}