resource "kubernetes_namespace" "rancher" {
  metadata {
    name = var.rancher_namespace
  }
}

resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/latest"
  chart      = "rancher"
  namespace  = kubernetes_namespace.rancher.metadata[0].name

  values = [yamlencode({
    hostname          = var.rancher_hostname
    bootstrapPassword = var.rancher_bootstrap_password
    ingress = {
      enabled = false
    }
    })
  ]
}

resource "kubernetes_manifest" "rancher_ingressroute" {
  depends_on = [kubernetes_namespace.rancher]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "rancher"
      namespace = kubernetes_namespace.rancher.metadata[0].name
      annotations = {
        "traefik.ingress.kubernetes.io/router.entrypoints"      = "websecure"
        "traefik.ingress.kubernetes.io/router.tls"              = "true"
        "traefik.ingress.kubernetes.io/router.tls.certresolver" = "letsencrypt"
      }
    }

    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`${var.rancher_hostname}`) && PathPrefix(`/`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "rancher"
              port = "main"
            }
          ]
        }
      ]

      tls = {
        certResolver = "letsencrypt"
      }
    }
  }
}