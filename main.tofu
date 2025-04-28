module "shared_infra" {
  source = "./shared"

  acme_email                  = var.acme_email
  local_path_provisioner_path = var.local_path_provisioner_path
}

module "monitoring" {
  source = "./modules/monitoring"

  grafana_hostname       = var.grafana_hostname
  grafana_admin_password = var.grafana_admin_password
  prometheus_retention   = var.prometheus_retention
  prometheus_storage     = var.prometheus_storage
  alertmanager_storage   = var.alertmanager_storage
  grafana_storage        = var.grafana_storage
}

variable "acme_email" {
  description = "Email address for ACME (Let's Encrypt) registration."
  type        = string
  sensitive   = true
}

variable "local_path_provisioner_path" {
  description = "Path on the node where local-path-provisioner will create PVs."
  type        = string
  default     = "/mnt/k8s"
}

variable "grafana_hostname" {
  description = "Hostname for accessing Grafana"
  type        = string
  default     = "grafana.local.lab"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
  default     = "prom-operator"
}

variable "prometheus_retention" {
  description = "Data retention period for Prometheus"
  type        = string
  default     = "10d"
}

variable "prometheus_storage" {
  description = "Storage size for Prometheus"
  type        = string
  default     = "10Gi"
}

variable "alertmanager_storage" {
  description = "Storage size for AlertManager"
  type        = string
  default     = "2Gi"
}

variable "grafana_storage" {
  description = "Storage size for Grafana"
  type        = string
  default     = "5Gi"
}