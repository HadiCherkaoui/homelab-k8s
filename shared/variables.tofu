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

variable "local_path_provisioner_path" {
  description = "Path on the node where local-path-provisioner will create PVs."
  type        = string
  default     = "/opt/local-path-provisioner"
}