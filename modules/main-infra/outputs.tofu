# Outputs for main infrastructure module

# Namespace output
output "namespace" {
  description = "The namespace where main infrastructure components are deployed"
  value       = kubernetes_namespace.main_infra.metadata[0].name
}

# Traefik outputs
output "traefik_enabled" {
  description = "Whether Traefik is enabled"
  value       = var.traefik_enabled
}

output "traefik_service_name" {
  description = "The name of the Traefik service"
  value       = var.traefik_enabled ? "traefik" : null
}

output "traefik_ip" {
  description = "IP address of the Traefik load balancer"
  value       = var.traefik_enabled && var.metallb_enabled ? data.kubernetes_service.traefik[0].status.0.load_balancer.0.ingress.0.ip : null
}

output "ingress_class_name" {
  description = "The name of the IngressClass to use for ingresses"
  value       = var.traefik_enabled ? kubernetes_ingress_class_v1.traefik[0].metadata[0].name : null
}

# Monitoring outputs
output "monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = var.monitoring_enabled
}

output "prometheus_service_name" {
  description = "The name of the Prometheus service"
  value       = var.monitoring_enabled ? "prometheus-operated" : null
}

output "grafana_service_name" {
  description = "The name of the Grafana service"
  value       = var.monitoring_enabled ? "prometheus-grafana" : null
}

output "grafana_url" {
  description = "The URL to access Grafana"
  value       = var.monitoring_enabled && var.traefik_enabled ? "https://grafana.${var.domain}" : null
}

# KubeSphere outputs
output "kubesphere_enabled" {
  description = "Whether KubeSphere is enabled"
  value       = var.kubesphere_enabled
}

output "kubesphere_url" {
  description = "The URL to access KubeSphere console"
  value       = var.kubesphere_enabled && var.traefik_enabled ? "https://kubesphere.${var.domain}" : null
}

# Digger outputs
output "digger_enabled" {
  description = "Whether Digger is enabled"
  value       = var.digger_enabled
}

output "digger_url" {
  description = "The URL to access Digger"
  value       = var.digger_enabled && var.traefik_enabled ? "https://digger.${var.domain}" : null
}