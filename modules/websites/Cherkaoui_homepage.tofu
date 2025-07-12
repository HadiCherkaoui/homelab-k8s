resource "kubernetes_deployment" "cherkaoui_homepage" {
  depends_on = [kubernetes_namespace.websites]
  metadata {
    name      = "cherkaoui_homepage"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }
  spec {
    selector {
      match_labels = {
        app = "cherkaoui_homepage"
      }
    }
    template {
      metadata {
        labels = {
          app = "cherkaoui_homepage"
        }
      }
      spec {
        container {
          name  = "cherkaoui_homepage"
          image = "registry.cherkaoui.ch/hadicherkaoui/cherkaoui-homepage:latest"
          port {
            container_port = 3000
            name           = "main"
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "cherkaoui_homepage" {
  metadata {
    name      = "cherkaoui_homepage"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }
  spec {
    selector = {
      app = "cherkaoui_homepage"
    }
    type = "ClusterIP"
    port {
      name        = "web"
      port        = 3000
      target_port = 3000
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_manifest" "cherkaoui_homepage_ingressroute" {
  depends_on = [kubernetes_namespace.websites]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "cherkaoui_homepage"
      namespace = kubernetes_namespace.websites.metadata[0].name
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
          match = "Host(`cherkaoui.ch`) && PathPrefix(`/`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "cherkaoui_homepage"
              port = 3000
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