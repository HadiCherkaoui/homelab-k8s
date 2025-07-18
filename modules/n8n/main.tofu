resource "kubernetes_namespace" "n8n" {
  metadata {
    name = "n8n"
  }
}

resource "helm_release" "n8n" {
  depends_on = [kubernetes_namespace.n8n]
  name       = "n8n"
  repository = "oci://8gears.container-registry.com/library"
  chart      = "n8n"
  namespace  = kubernetes_namespace.n8n.metadata[0].name
  version    = "1.0.10"

  values = yamlencode({
    scaling = {
      enabled = true
    }
    redis = {
      enabled = true
    }
    main = {
      persistence = {
        enabled = true
      }
    }
    worker = {
      persistence = {
        enabled = true
      }
    }
  })
}

resource "kubernetes_manifest" "n8n_ingressroute" {
  depends_on = [kubernetes_namespace.n8n]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "n8n"
      namespace = kubernetes_namespace.n8n.metadata[0].name
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
          match = "Host(`${var.n8n_hostname}`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "n8n"
              port = "http"
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