# Installs local-path-provisioner for local storage

resource "helm_release" "local_path_provisioner" {
  name       = "local-path-provisioner"
  repository = "https://charts.containeroo.ch/"
  chart      = "local-path-provisioner"
  namespace  = "kube-system" # Deployed in kube-system for cluster-wide access

  set {
    name  = "storageClass.defaultClass"
    value = "true"
  }

  set {
    name  = "nodePathMap[0].node"
    value = "k8s-node"
  }

  set {
    name  = "nodePathMap[0].paths[0]"
    value = var.local_path_provisioner_path
  }

  # Add a default path for any non-listed nodes
  set {
    name  = "nodePathMap[1].node"
    value = "DEFAULT_PATH_FOR_NON_LISTED_NODES"
  }

  set {
    name  = "nodePathMap[1].paths[0]"
    value = var.local_path_provisioner_path
  }
}