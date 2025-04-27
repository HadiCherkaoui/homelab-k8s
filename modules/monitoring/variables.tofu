variable "monitoring_namespace" {
  description = "Namespace for monitoring components (Prometheus, Grafana)"
  type        = string
  default     = "monitoring"
}

variable "grafana_hostname" {
  description = "Hostname for accessing Grafana"
  type        = string
  default     = "grafana.local.lab" # Replace with your desired hostname
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
  default     = "prom-operator" # Change this in production!
}

variable "prometheus_retention" {
  description = "Data retention period for Prometheus"
  type        = string
  default     = "10d" # 10 days retention - suitable for homelab
}

variable "prometheus_storage" {
  description = "Storage size for Prometheus"
  type        = string
  default     = "10Gi" # Adjust based on your homelab storage capacity
}

variable "alertmanager_storage" {
  description = "Storage size for AlertManager"
  type        = string
  default     = "2Gi" # Alertmanager usually needs less storage than Prometheus
}

variable "grafana_storage" {
  description = "Storage size for Grafana"
  type        = string
  default     = "5Gi" # Storage for dashboards and datasources
}