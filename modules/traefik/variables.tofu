variable "traefik_namespace" {
  description = "Namespace for Traefik resources"
  type        = string
  default     = "traefik"
}

variable "acme_email" {
  description = "Email address for ACME (Let's Encrypt) registration."
  type        = string
  sensitive   = true
}

variable "traefik_version" {
  type = string
}