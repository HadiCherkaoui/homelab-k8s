# Variables for homelab Kubernetes infrastructure

# Kubernetes configuration
variable "kube_config_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context to use from the kubeconfig file"
  type        = string
  default     = ""
}

# Domain configuration
variable "domain" {
  description = "Base domain for all services"
  type        = string
  default     = "cherkaoui.ch"
}

# Storage configuration
variable "local_storage_path" {
  description = "Path to the local storage directory on the host"
  type        = string
  default     = "/mnt/k8s"
}

variable "local_storage_size" {
  description = "Size of the local storage volume"
  type        = string
  default     = "6000Gi"
}

variable "node_hostname" {
  description = "Hostname of the Kubernetes node where local storage is available"
  type        = string
  default     = "k8s-node"
}

# Component enablement
variable "traefik_enabled" {
  description = "Whether to enable Traefik ingress controller"
  type        = bool
  default     = true
}

variable "monitoring_enabled" {
  description = "Whether to enable monitoring stack (Prometheus, Grafana, etc.)"
  type        = bool
  default     = true
}

variable "kubesphere_enabled" {
  description = "Whether to enable KubeSphere dashboard"
  type        = bool
  default     = true
}

variable "digger_enabled" {
  description = "Whether to enable Digger (OpenTofu GitOps)"
  type        = bool
  default     = false
}

variable "cert_manager_enabled" {
  description = "Whether to enable cert-manager for certificate automation"
  type        = bool
  default     = true
}

variable "letsencrypt_enabled" {
  description = "Whether to enable Let's Encrypt certificate issuers"
  type        = bool
  default     = true
}

# Let's Encrypt configuration
variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt notifications"
  type        = string
  default     = "admin@cherkaoui.ch"
}

# MetalLB configuration
variable "metallb_enabled" {
  description = "Whether to enable MetalLB for load balancing"
  type        = bool
  default     = true
}

variable "metallb_addresses" {
  description = "IP address range for MetalLB to use (e.g., ['192.168.1.240-192.168.1.250'])"
  type        = list(string)
  default     = ["192.168.1.240-192.168.1.250"]
}
