resource "helm_release" "sonarr" {
  depends_on = [kubernetes_namespace.media, helm_release.qbittorrent]
  name       = "sonarr"
  repository = "oci://tccr.io/truecharts"
  chart      = "sonarr"
  namespace  = kubernetes_namespace.media.metadata[0].name
  version    = var.sonarr_version

  values = [
    yamlencode({
      persistence = {
        config = {
          enabled = true
          size    = "2Gi"
        }
        shows = {
          enabled       = true
          existingClaim = kubernetes_persistent_volume_claim.plex_media.metadata[0].name
          mountPath     = "/shows"
          subPath       = "shows"
        }
        qbitshows = {
          enabled       = true
          existingClaim = kubernetes_persistent_volume_claim.qbit_media.metadata[0].name
          mountPath     = "/movies-shows"
          subPath       = "movies-shows"
        }
      }
    })
  ]
}