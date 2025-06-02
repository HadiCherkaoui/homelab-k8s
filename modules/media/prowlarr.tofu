resource "helm_release" "prowlarr" {
  depends_on = [kubernetes_namespace.media]
  name       = "prowlarr"
  chart      = "prowlarr"
  namespace  = kubernetes_namespace.media.metadata[0].name
  repository = "oci://tccr.io/truecharts"
  version    = var.prowlarr_version

  values = [
    yamlencode({
      persistence = {
        config = {
          enabled = true
          size    = "2Gi"
        }
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
  version    = var.flaresolverr_version

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