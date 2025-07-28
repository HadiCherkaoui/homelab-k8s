resource "kubernetes_namespace" "websites" {
  metadata {
    name = "websites"
  }
}

resource "kubernetes_deployment" "hadi" {
  depends_on = [kubernetes_namespace.websites]

  metadata {
    name      = "hadi"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }

  spec {
    selector {
      match_labels = {
        app = "hadi"
      }
    }
    template {
      metadata {
        labels = {
          app = "hadi"
        }
      }
      spec {
        container {
          name  = "hadi"
          image = "registry.cherkaoui.ch/hadicherkaoui/portfolio:latest"
          port {
            container_port = 3000
            name           = "main"
          }
          env {
            name  = "NEXT_PUBLIC_DISCORD_WEBHOOK_URL"
            value = var.next_public_discord_webhook_url
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hadi" {
  metadata {
    name      = "hadi"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }

  spec {
    selector = {
      app = "hadi"
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

resource "kubernetes_persistent_volume_claim" "websites" {
  metadata {
    name      = "websites"
    namespace = kubernetes_namespace.websites.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
  wait_until_bound = false
}

resource "kubernetes_manifest" "hadi_ingressroute" {
  depends_on = [kubernetes_namespace.websites]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "hadi"
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
          match = "Host(`${var.hadi_hostname}`) && PathPrefix(`/`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "hadi"
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