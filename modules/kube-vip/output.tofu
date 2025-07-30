output "kube_vip_namespace" {
  description = "Namespace where kube-vip is deployed"
  value       = kubernetes_namespace.kube_vip.metadata[0].name
}

output "kube_vip_service_account" {
  description = "Service account used by kube-vip"
  value       = kubernetes_service_account.kube_vip.metadata[0].name
}
