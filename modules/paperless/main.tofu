resource "kubernetes_namespace" "paperless" {
  metadata {
    name = var.paperless_namespace
  }
}

resource "kubernetes_persistent_volume_claim" "paperless_data" {
  depends_on       = [kubernetes_namespace.paperless]
  wait_until_bound = false
  metadata {
    name      = "paperless-data"
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "paperless_media" {
  depends_on       = [kubernetes_namespace.paperless]
  wait_until_bound = false
  metadata {
    name      = "paperless-media"
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "100Gi"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "paperless_consume" {
  depends_on       = [kubernetes_namespace.paperless]
  wait_until_bound = false
  metadata {
    name      = "paperless-consume"
    namespace = kubernetes_namespace.paperless.metadata[0].name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}

resource "helm_release" "cnpg_operator" {
  depends_on = [kubernetes_namespace.paperless]

  name       = "cnpg-operator"
  repository = "https://cloudnative-pg.github.io/charts"
  chart      = "cloudnative-pg"
  namespace  = kubernetes_namespace.paperless.metadata[0].name
  version    = var.cnpg_operator_version
}

resource "helm_release" "paperless" {
  depends_on = [helm_release.cnpg_operator, kubernetes_namespace.paperless]

  name       = "paperless"
  repository = "oci://tccr.io/truecharts"
  chart      = "paperless-ngx"
  namespace  = kubernetes_namespace.paperless.metadata[0].name
  version    = var.paperless_version

  values = [
    yamlencode({
      persistence = {
        data = {
          enabled       = true
          mountPath     = "/data"
          existingClaim = "paperless-data"
        }
        consume = {
          enabled       = true
          mountPath     = "/consume"
          existingClaim = "paperless-consume"
        }
        media = {
          enabled       = true
          mountPath     = "/media"
          existingClaim = "paperless-media"
        }
      }
      workload = {
        main = {
          podSpec = {
            containers = {
              main = {
                env = {
                  PAPERLESS_ADMIN_USER              = var.paperless_admin_user
                  PAPERLESS_ADMIN_PASSWORD          = var.paperless_admin_password
                  PAPERLESS_ADMIN_MAIL              = var.paperless_admin_mail
                  PAPERLESS_OCR_LANGUAGE            = "deu"
                  PAPERLESS_OCR_LANGUAGES           = "eng fra deu spa ita"
                  PAPERLESS_CONSUMER_POLLING        = 120
                  PAPERLESS_CSRF_TRUSTED_ORIGINS    = "https://${var.paperless_hostname}"
                  PAPERLESS_ALLOWED_HOSTS           = "${var.paperless_hostname}"
                  PAPERLESS_SECURE_PROXY_SSL_HEADER = "HTTP_X_FORWARDED_PROTO,https"
                  PAPERLESS_FILENAME_FORMAT         = "{owner_username}/{created_year}/{correspondent}/{doc_pk}"
                }
              }
            }
          }
        }
      }
    })
  ]
}

resource "kubernetes_manifest" "paperless_ingressroute" {
  depends_on = [kubernetes_namespace.paperless]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "paperless"
      namespace = kubernetes_namespace.paperless.metadata[0].name
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
          match = "Host(`${var.paperless_hostname}`) && PathPrefix(`/`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "paperless-paperless-ngx"
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
