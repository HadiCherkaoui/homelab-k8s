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
            securityContext = {
              sysctls = [
                {
                  name  = "net.ipv4.ip_forward"
                  value = "1"
                },
                {
                  name  = "net.ipv4.conf.all.src_valid_mark"
                  value = "1"
                },
                {
                  name  = "net.ipv6.conf.all.disable_ipv6"
                  value = "0"
                },
                {
                  name  = "net.ipv6.conf.all.forwarding"
                  value = "1"
                },
                {
                  name  = "net.ipv6.conf.default.forwarding"
                  value = "1"
                }
              ]
            }
            containers = {
              main = {
                securityContext = {
                  capabilities = {
                    add = ["NET_ADMIN", "SYS_MODULE"]
                  }
                }
                env = {
                  # v15 uses minimal environment variables
                  # Most configuration is done via web UI
                  PORT     = 51821
                  HOST     = "0.0.0.0"
                  INSECURE = false
                }
              }
            }
          }
        }
      }
    })
  ]
}