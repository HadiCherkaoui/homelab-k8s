variable "monitoring_namespace" {
  description = "Namespace for monitoring components (Prometheus, Grafana)"
  type        = string
  default     = "monitoring"
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