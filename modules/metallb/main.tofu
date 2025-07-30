resource "kubernetes_namespace" "metallb" {
  metadata {
    name = "metallb"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "helm_release" "metallb" {
  name       = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  namespace  = kubernetes_namespace.metallb.metadata[0].name

  depends_on = [kubernetes_namespace.metallb]
}

resource "kubernetes_manifest" "metallb_address_pool" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "IPAddressPool"
    metadata = {
      name      = "default-pool"
      namespace = kubernetes_namespace.metallb.metadata[0].name
    }
    spec = {
      addresses = var.metallb_ip_range
    }
  }

  depends_on = [helm_release.metallb, kubernetes_namespace.metallb]
}

resource "kubernetes_manifest" "metallb_l2_advertisement" {
  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind       = "L2Advertisement"
    metadata = {
      name      = "default-l2"
      namespace = kubernetes_namespace.metallb.metadata[0].name
    }
    spec = {
      ipAddressPools = ["default-pool"]
    }
  }

  depends_on = [kubernetes_manifest.metallb_address_pool, helm_release.metallb, kubernetes_namespace.metallb]
}

