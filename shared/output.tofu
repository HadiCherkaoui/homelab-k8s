output "traefik_service_status" {
  description = "Status of the Traefik LoadBalancer service."
  value       = helm_release.traefik.status
}