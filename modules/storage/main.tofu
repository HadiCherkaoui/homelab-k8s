resource "helm_release" "local_path_provisioner" {
  name       = "local-path-provisioner"
  repository = "https://charts.containeroo.ch/"
  chart      = "local-path-provisioner"
  namespace  = "kube-system"

  values = [
    yamlencode({
      storageClass = {
        defaultClass = true
      }
      nodePathMap = [
        {
          node = "k8s-node"
          paths = [
            var.local_path_provisioner_path
          ]
        },
        {
          node = "DEFAULT_PATH_FOR_NON_LISTED_NODES"
          paths = [
            var.local_path_provisioner_path
          ]
        }
      ]
    })
  ]
}