resource "helm_release" "radarr" {
  depends_on = [kubernetes_namespace.media, helm_release.qbittorrent]
  name       = "radarr"
  repository = "oci://tccr.io/truecharts"
  chart      = "radarr"
  namespace  = kubernetes_namespace.media.metadata[0].name

  values = [
    yamlencode({
      persistence = {
        config = {
          enabled = true
          size    = "2Gi"
        }
        movies = {
          enabled       = true
          existingClaim = kubernetes_persistent_volume_claim.plex_media.metadata[0].name
          mountPath     = "/movies"
          subPath       = "movies"
        }
        qbitmovies = {
          enabled       = true
          existingClaim = kubernetes_persistent_volume_claim.qbit_media.metadata[0].name
          mountPath     = "/movies-shows"
          subPath       = "movies-shows"
        }
      }
    })
  ]
}