variable "traefik_namespace" {
  description = "Namespace to install Traefik into."
  type        = string
  default     = "traefik"
}

variable "metallb_namespace" {
  description = "Namespace to install MetalLB into."
  type        = string
  default     = "metallb-system"
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

variable "metallb_ip_range" {
  description = "IP address range for MetalLB LoadBalancer services."
  type        = string
  default     = "192.168.1.200-192.168.1.220"
}