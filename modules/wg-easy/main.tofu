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
                env = {
                  WG_DEFAULT_DNS   = "10.96.0.10"
                  PASSWORD_HASH    = var.wg_easy_password_hash
                  WG_HOST          = var.wg_easy_hostname
                  WG_PORT          = 51820
                  UI_TRAFFIC_STATS = true
                  WG_ALLOWED_IPS   = "10.0.0.0/8,0.0.0.0/0"
                  WG_MTU           = 1420
                }
              }
            }
          }
        }
      }
    })
  ]
}