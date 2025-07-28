resource "helm_release" "prowlarr" {
  depends_on = [kubernetes_namespace.media]
  name       = "prowlarr"
  chart      = "prowlarr"
  namespace  = kubernetes_namespace.media.metadata[0].name
  repository = "oci://tccr.io/truecharts"
  version    = "20.1.1"

  values = [
    yamlencode({
      persistence = {
        config = {
          enabled = true
          size    = "2Gi"
        }
      }
      resources = {
        limits   = null
        requests = null
      }
    })
  ]
}

resource "helm_release" "flaresolverr" {
  depends_on = [kubernetes_namespace.media]
  name       = "flaresolverr"
  chart      = "flaresolverr"
  namespace  = kubernetes_namespace.media.metadata[0].name
  repository = "oci://tccr.io/truecharts"
  version    = "15.5.1"

  values = [
    yamlencode({
      persistence = {
        config = {
          enabled = true
          size    = "1Gi"
        }
      }
    })
  ]
}