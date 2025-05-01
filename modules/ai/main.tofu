resource "kubernetes_namespace" "openwebui" {
  metadata {
    name = "openwebui"
  }
}

resource "helm_release" "openwebui" {
  depends_on = [kubernetes_namespace.openwebui]

  name       = "openwebui"
  repository = "https://helm.openwebui.com"
  chart      = "open-webui"
  namespace  = kubernetes_namespace.openwebui.metadata[0].name

  values = [
    yamlencode({
      sso = {
        enabled = true
        github = {
          enabled      = true
          clientId     = var.github_client_id
          clientSecret = var.github_client_secret
        }
        google = {
          enabled      = true
          clientId     = var.google_client_id
          clientSecret = var.google_client_secret
        }
        microsoft = {
          enabled      = true
          clientId     = var.microsoft_client_id
          clientSecret = var.microsoft_client_secret
          tenantId     = var.microsoft_tenant_id
        }
      }
    })
  ]
}

resource "kubernetes_manifest" "openwebui_ingressroute" {
  depends_on = [kubernetes_namespace.openwebui]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "openwebui"
      namespace = kubernetes_namespace.openwebui.metadata[0].name
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
          match = "Host(`${var.openwebui_hostname}`) && PathPrefix(`/`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "openwebui"
              port = 80
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