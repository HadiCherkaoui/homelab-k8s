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

variable "plex_hostname" {
  description = "Hostname for Plex"
  type        = string
  default     = "plex.local.lab"
}

variable "jellyfin_hostname" {
  description = "Hostname for Jellyfin"
  type        = string
  default     = "jellyfin.local.lab"
}

variable "plex_claim" {
  description = "Plex claim"
  type        = string
  sensitive   = true
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

variable "scolx_hostname" {
  description = "Hostname for ScolX"
  type        = string
}

variable "scolx_jwt_secret" {
  description = "JWT secret for ScolX"
  type        = string
  sensitive   = true
}

variable "scolx_admin_user" {
  description = "Admin user for ScolX"
  type        = string
}

variable "scolx_admin_password" {
  description = "Admin password for ScolX"
  type        = string
  sensitive   = true
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

variable "cilium_l2_ip_range" {
  description = "IP range for Cilium L2 announcements load balancer"
  type        = list(string)
}

variable "openvpn_user" {
  type      = string
  sensitive = true
}

variable "openvpn_password" {
  type      = string
  sensitive = true
}

variable "openvpn_config" {
  type      = string
  sensitive = true
}

variable "notifiarr_apikey" {
  type      = string
  sensitive = true
}

variable "wg_easy_password_hash" {
  type      = string
  sensitive = true
}

variable "wg_easy_hostname" {
  type    = string
  default = "wg-easy.local.lab"
}

variable "hadi_hostname" {
  type = string
}

variable "laura_hostname" {
  type = string
}

variable "quillium_docs_hostname" {
  type = string
}

variable "docs_hostname" {
  type = string
}

variable "github_client_id" {
  type      = string
  sensitive = true
}

variable "github_client_secret" {
  type      = string
  sensitive = true
}

variable "google_client_id" {
  type      = string
  sensitive = true
}

variable "google_client_secret" {
  type      = string
  sensitive = true
}

variable "microsoft_client_id" {
  type      = string
  sensitive = true
}

variable "microsoft_client_secret" {
  type      = string
  sensitive = true
}

variable "microsoft_tenant_id" {
  type      = string
  sensitive = true
}

variable "openwebui_hostname" {
  type = string
}

variable "paperless_admin_user" {
  type = string
}

variable "paperless_admin_password" {
  type      = string
  sensitive = true
}

variable "paperless_admin_mail" {
  type = string
}

variable "paperless_hostname" {
  type = string
}

variable "gitlab_domain" {
  type        = string
  description = "GitLab domain"
}

variable "gitlab_hostname" {
  type        = string
  description = "GitLab hostname"
}

variable "gitlab_registry_hostname" {
  type        = string
  description = "GitLab registry hostname"
}

variable "gitlab_minio_hostname" {
  type        = string
  description = "GitLab minio hostname"
}

variable "gitlab_kas_hostname" {
  type        = string
  description = "GitLab kas hostname"
}

variable "gitlab_smtp_password" {
  type      = string
  sensitive = true
}

variable "protonmail_username" {
  type = string
}

variable "gitlab_agent_token" {
  type      = string
  sensitive = true
}

variable "gitlab_registry_username" {
  description = "Username for GitLab Container Registry auth (e.g. Deploy Token username)"
  type        = string
  sensitive   = true
}

variable "gitlab_registry_password" {
  description = "Password/token for GitLab Container Registry auth (e.g. Deploy Token)"
  type        = string
  sensitive   = true
}

variable "pgadmin_default_email" {
  description = "Default email for pgadmin"
  type        = string
}

variable "pgadmin_default_password" {
  description = "Default password for pgadmin"
  type        = string
  sensitive   = true
}

variable "scolx_postgres_password" {
  description = "Password for ScolX Postgres"
  type        = string
  sensitive   = true
}
