# Output important information
output "kubesphere_url" {
  description = "URL to access KubeSphere dashboard"
  value       = module.main_infra.kubesphere_enabled ? "https://kubesphere.${var.domain}" : null
}

output "grafana_url" {
  description = "URL to access Grafana dashboard"
  value       = module.main_infra.grafana_url
}

output "traefik_ip" {
  description = "IP address of the Traefik load balancer"
  value       = module.main_infra.traefik_ip
}

output "storage_class_name" {
  description = "Name of the default storage class"
  value       = module.shared.storage_class_name
}