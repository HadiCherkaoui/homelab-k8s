variable "scolx_hostname" {
  description = "Hostname for ScolX"
  type        = string
}

variable "jwt_secret" {
  description = "JWT secret for ScolX"
  type        = string
  sensitive   = true
}

variable "scolx_admin_password" {
  description = "Admin password for ScolX"
  type        = string
  sensitive   = true
}

variable "scolx_admin_user" {
  description = "Admin user for ScolX"
  type        = string
}

variable "registry_server" {
  description = "Container registry hostname (e.g. registry.cherkaoui.ch)"
  type        = string
}

variable "registry_username" {
  description = "Username for registry auth (e.g. GitLab Deploy Token username)"
  type        = string
  sensitive   = true
}

variable "registry_password" {
  description = "Password/token for registry auth (e.g. GitLab Deploy Token)"
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