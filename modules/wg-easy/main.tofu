resource "kubernetes_namespace" "vpn" {
  metadata {
    name = var.vpn_namespace
  }
}

resource "helm_release" "wg_easy" {
  depends_on = [kubernetes_namespace.vpn]
  name       = "wg-easy"
  chart      = "wg-easy"
  namespace  = kubernetes_namespace.vpn.metadata[0].name
  repository = "oci://tccr.io/truecharts"
  version    = "18.1.0"

  values = [
    yamlencode({
      persistence = {
        config = {
          enabled   = true
          mountPath = "/etc/wireguard"
          size      = "1Gi"
        }
      }
      workload = {
        main = {
          podSpec = {
            hostNetwork = true
            dnsPolicy   = "ClusterFirstWithHostNet"
            containers = {
              main = {
                securityContext = {
                  capabilities = {
                    add = ["NET_ADMIN", "SYS_MODULE"]
                  }
                }
                env = {
                  PORT     = 51821
                  HOST     = "0.0.0.0"
                  INSECURE = true
                }
              }
            }
          }
        }
      }
    })
  ]
}