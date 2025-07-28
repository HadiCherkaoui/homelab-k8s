resource "kubernetes_persistent_volume_claim" "qbit_media" {
  depends_on = [kubernetes_namespace.media]
  metadata {
    name      = "qbit-media"
    namespace = kubernetes_namespace.media.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "200Gi"
      }
    }
  }
  wait_until_bound = false
}

resource "helm_release" "qbittorrent" {
  depends_on = [kubernetes_namespace.media, kubernetes_persistent_volume_claim.qbit_media]
  name       = "qbittorrent"
  repository = "oci://tccr.io/truecharts"
  chart      = "qbittorrent"
  namespace  = kubernetes_namespace.media.metadata[0].name
  version    = "23.1.1"

  values = [
    yamlencode({
      podOptions = {
        dnsPolicy = "None"
        dnsConfig = {
          nameservers = ["1.1.1.1"]
          searches    = ["media.svc.cluster.local", "svc.cluster.local", "cluster.local"]
          options = [
            {
              name  = "ndots"
              value = "1"
            }
          ]
        }
      }
      persistence = {
        config = {
          enabled = true
          size    = "2Gi"
        }
        movies-shows = {
          enabled       = true
          existingClaim = "qbit-media"
          mountPath     = "/movies-shows"
          subPath       = "movies-shows"
        }
      }
      addons = {
        vpn = {
          enabled               = true
          type                  = "gluetun"
          killSwitch            = true
          excludedNetworks_IPv4 = ["192.168.1.0/24"]
          excludedNetworks_IPv6 = []
          env = {
            DNS_ADDRESS               = "1.1.1.1"
            FIREWALL_OUTBOUND_SUBNETS = "1.1.1.1/32,172.16.0.0/16,172.17.0.0/16,192.168.1.0/24,104.16.132.229/32,10.2.0.0/16"
            DNS_KEEP_NAMESERVER       = "off"
            VPN_TYPE                  = "openvpn"
            VPN_SERVICE_PROVIDER      = "protonvpn"
            VPN_PORT_FORWARDING       = "on"
            OPENVPN_USER              = var.openvpn_user
            OPENVPN_PASSWORD          = var.openvpn_password
            OPENVPN_CONFIG            = var.openvpn_config
            FIREWALL_VPN_INPUT_PORTS  = "59241"
          }
        }
      }
    })
  ]
}