# Data sources for the main-infra module

# Get Traefik service information for outputs
data "kubernetes_service" "traefik" {
  count = var.traefik_enabled && var.metallb_enabled ? 1 : 0

  metadata {
    name      = "traefik"
    namespace = kubernetes_namespace.main_infra.metadata[0].name
  }

  depends_on = [
    helm_release.traefik,
    helm_release.metallb,
    kubectl_manifest.metallb_l2_advertisement
  ]
}
