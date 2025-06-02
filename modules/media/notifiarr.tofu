resource "helm_release" "notifiarr" {
  depends_on = [kubernetes_namespace.media]
  name       = "notifiarr"
  chart      = "notifiarr"
  namespace  = kubernetes_namespace.media.metadata[0].name
  repository = "oci://tccr.io/truecharts"
  version    = var.notifiarr_version

  values = [
    yamlencode({
      persistence = {
        config = {
          enabled = true
          size    = "2Gi"
        }
      }
      notifiarr = {
        apikey = var.notifiarr_apikey
      }
    })
  ]
}