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

variable "gitlab_version" {
  type        = string
  description = "GitLab version"
}

variable "gitlab_agent_version" {
  type        = string
  description = "GitLab agent version"
}

variable "proton_birdge_version" {
  type        = string
  description = "Protonmail bridge version"
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