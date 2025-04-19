# MetalLB configuration for bare metal load balancing

# Deploy MetalLB using Helm if enabled
resource "helm_release" "metallb" {
  count      = var.metallb_enabled ? 1 : 0
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = local.metallb_chart_version
  namespace  = kubernetes_namespace.main_infra.metadata[0].name

  # Set default values for MetalLB
  values = [
    yamlencode({
      # Basic configuration
      controller = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "50Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "100Mi"
          }
        }
      }
      speaker = {
        resources = {
          requests = {
            cpu    = "100m"
            memory = "50Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "100Mi"
          }
        }
      }
    }),
    yamlencode(var.metallb_values) # Merge with any additional values provided
  ]

  depends_on = [
    kubernetes_namespace.main_infra
  ]
}

# Configure MetalLB address pool
resource "kubectl_manifest" "metallb_address_pool" {
  count = var.metallb_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "default-pool"
      namespace = kubernetes_namespace.main_infra.metadata[0].name
    }
    spec = {
      addresses = var.metallb_addresses
    }
  })

  depends_on = [
    helm_release.metallb
  ]
}

# Configure MetalLB L2 advertisement
resource "kubectl_manifest" "metallb_l2_advertisement" {
  count = var.metallb_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "default-advertisement"
      namespace = kubernetes_namespace.main_infra.metadata[0].name
    }
    spec = {
      ipAddressPools = ["default-pool"]
    }
  })

  depends_on = [
    kubectl_manifest.metallb_address_pool
  ]
}
