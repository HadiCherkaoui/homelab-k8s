# Outputs for shared Kubernetes configuration

output "kube_config_path" {
  description = "Path to the kubeconfig file"
  value       = var.kube_config_path
}

output "kube_context" {
  description = "Kubernetes context being used"
  value       = var.kube_context
}

# Storage class outputs
output "storage_class_name" {
  description = "Name of the default storage class"
  value       = kubernetes_storage_class.local_path.metadata[0].name
}

output "local_storage_path" {
  description = "Path to the local storage on the host"
  value       = var.local_storage_path
}

output "local_path_provisioner_namespace" {
  description = "Namespace where the Local Path Provisioner is deployed"
  value       = kubernetes_namespace.local_path_storage.metadata[0].name
}
