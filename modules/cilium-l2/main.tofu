resource "kubernetes_manifest" "cilium_l2_announcement_policy" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumL2AnnouncementPolicy"
    metadata = {
      name = "default-l2-policy"
    }
    spec = {
      serviceSelector = {
        matchLabels = {}
      }
      nodeSelector = {
        matchLabels = {}
      }
      interfaces = [
        "enp6s18"
      ]
      externalIPs     = true
      loadBalancerIPs = true
    }
  }
}

resource "kubernetes_manifest" "cilium_loadbalancer_ip_pool" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"
    metadata = {
      name = "default-pool"
    }
    spec = {
      blocks = [
        for cidr in var.cilium_l2_ip_range : {
          cidr = cidr
        }
      ]
    }
  }
}
