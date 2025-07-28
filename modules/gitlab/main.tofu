resource "kubernetes_namespace" "gitlab" {
  metadata {
    name = "gitlab"
  }
}

resource "kubernetes_secret" "gitlab_smtp_password" {
  metadata {
    name      = "gitlab-smtp-password"
    namespace = kubernetes_namespace.gitlab.metadata[0].name
  }

  data = {
    smtp-password = var.gitlab_smtp_password
  }
}

resource "helm_release" "gitlab" {
  name       = "gitlab"
  repository = "https://charts.gitlab.io"
  chart      = "gitlab"
  namespace  = kubernetes_namespace.gitlab.metadata[0].name
  version    = "9.0.2"

  depends_on = [kubernetes_namespace.gitlab, kubernetes_secret.gitlab_smtp_password]

  values = [
    yamlencode({
      global = {
        appConfig = {
          terraformState = {
            enabled = true
            bucket  = "gitlab-terraform-state"
          }
        }
        edition = "ce"
        hosts = {
          domain = var.gitlab_domain
          https  = true
          gitlab = {
            name  = var.gitlab_hostname
            https = true
          }
          registry = {
            name  = var.gitlab_registry_hostname
            https = true
          }
          minio = {
            name  = var.gitlab_minio_hostname
            https = true
          }
          kas = {
            name  = var.gitlab_kas_hostname
            https = true
          }
          ssh = var.gitlab_hostname
        }
        ingress = {
          enabled              = false
          configureCertmanager = false
          tls = {
            enabled = false
          }
        }
        smtp = {
          enabled   = true
          address   = "proton-birdge-protonmail-bridge"
          port      = 25
          user_name = var.protonmail_username
          password = {
            secret = "gitlab-smtp-password"
            key    = "smtp-password"
          }
          domain              = "proton-birdge-protonmail-bridge.gitlab.svc.cluster.local"
          authentication      = "plain"
          starttls_auto       = true
          openssl_verify_mode = "none"
        }
        email = {
          from           = var.protonmail_username
          display_name   = "Cherkaoui Gitlab"
          reply_to       = var.protonmail_username
          subject_suffix = ""
        }
        monitoring = {
          enabled = true
        }
      }
      gitlab = {
        migrations = {
          resources = { requests = {} }
        }
        webservice = {
          minReplicas = 1
          maxReplicas = 1
          autoscaling = {
            enabled = true
          }
        }
        sidekiq = {
          minReplicas = 1
          maxReplicas = 1
          autoscaling = {
            enabled = true
          }
        }
        gitlab-shell = {
          minReplicas = 1
        }
        registry = {
          minReplicas = 1
        }
        kas = {
          minReplicas = 1
          maxReplicas = 1
          autoscaling = {
            enabled = true
          }
        }
      }
      installCertmanager = false

      nginx-ingress = {
        enabled = false
      }
      prometheus = {
        install = false
      }
    })
  ]
}

resource "helm_release" "proton_birdge" {
  name       = "proton-birdge"
  repository = "oci://tccr.io/truecharts"
  chart      = "protonmail-bridge"
  namespace  = kubernetes_namespace.gitlab.metadata[0].name
  version    = "17.1.0"

  depends_on = [kubernetes_namespace.gitlab]
}

resource "helm_release" "gitlab_agent" {
  name       = "gitlab-agent"
  repository = "https://charts.gitlab.io"
  chart      = "gitlab-agent"
  namespace  = kubernetes_namespace.gitlab.metadata[0].name
  version    = "2.15.0"

  depends_on = [kubernetes_namespace.gitlab, kubernetes_service_account.gitlab_agent, kubernetes_cluster_role_binding.gitlab_agent_admin]

  values = [
    yamlencode({
      rbac = {
        create = true
      }
      serviceAccount = {
        create = false
        name   = kubernetes_service_account.gitlab_agent.metadata[0].name
      }
      config = {
        kasAddress = "wss://${var.gitlab_kas_hostname}"
        token      = var.gitlab_agent_token
      }
      serviceMonitor = {
        enabled = true
      }
    })
  ]
}

resource "kubernetes_service_account" "gitlab_agent" {
  metadata {
    name      = "gitlab-agent"
    namespace = kubernetes_namespace.gitlab.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "gitlab_agent_admin" {
  metadata {
    name = "gitlab-agent-cluster-admin-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.gitlab_agent.metadata[0].name
    namespace = kubernetes_service_account.gitlab_agent.metadata[0].namespace
  }
}

resource "kubernetes_cluster_role_binding" "gitlab_default_admin" {
  metadata {
    name = "gitlab-default-cluster-admin-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = kubernetes_namespace.gitlab.metadata[0].name
  }
}

resource "kubernetes_manifest" "gitlab_ssh_ingressroutetcp" {
  depends_on = [kubernetes_namespace.gitlab]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRouteTCP"

    metadata = {
      name      = "gitlab-ssh"
      namespace = kubernetes_namespace.gitlab.metadata[0].name
    }

    spec = {
      entryPoints = ["ssh"]
      routes = [
        {
          match = "HostSNI(`*`)"
          kind  = "Rule"
          services = [
            {
              name = "gitlab-gitlab-shell"
              port = "ssh"
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "gitlab_ingressroute" {
  depends_on = [kubernetes_namespace.gitlab]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "gitlab"
      namespace = kubernetes_namespace.gitlab.metadata[0].name
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
          match = "Host(`${var.gitlab_hostname}`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "gitlab-webservice-default"
              port = "http-workhorse"
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

resource "kubernetes_manifest" "gitlab_registry_ingressroute" {
  depends_on = [kubernetes_namespace.gitlab]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "gitlab-registry"
      namespace = kubernetes_namespace.gitlab.metadata[0].name
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
          match = "Host(`${var.gitlab_registry_hostname}`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "gitlab-registry"
              port = "http-registry"
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

resource "kubernetes_manifest" "gitlab_minio_ingressroute" {
  depends_on = [kubernetes_namespace.gitlab]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "gitlab-minio"
      namespace = kubernetes_namespace.gitlab.metadata[0].name
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
          match = "Host(`${var.gitlab_minio_hostname}`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "gitlab-minio-svc"
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

resource "kubernetes_manifest" "gitlab_kas_ingressroute" {
  depends_on = [kubernetes_namespace.gitlab]
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "gitlab-kas"
      namespace = kubernetes_namespace.gitlab.metadata[0].name
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
          match = "Host(`${var.gitlab_kas_hostname}`)"
          kind  = "Rule"
          middlewares = [
            {
              name      = "security-headers"
              namespace = "traefik"
            }
          ]
          services = [
            {
              name = "gitlab-kas"
              port = "tcp-kas-external-api"
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