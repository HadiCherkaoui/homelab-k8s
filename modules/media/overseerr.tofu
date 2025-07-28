resource "helm_release" "overseerr" {
  depends_on = [kubernetes_namespace.media]
  name       = "overseerr"
  chart      = "overseerr"
  namespace  = kubernetes_namespace.media.metadata[0].name
  repository = "oci://tccr.io/truecharts"
  version    = "16.1.0"

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