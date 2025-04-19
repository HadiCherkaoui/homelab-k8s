# Variables for main infrastructure components

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

# General variables
variable "domain" {
  description = "Base domain for all services"
  type        = string
  default     = "cherkaoui.ch"
}

# Traefik variables
variable "traefik_enabled" {
  description = "Whether to enable Traefik ingress controller"
  type        = bool
  default     = true
}

variable "traefik_chart_version" {
  description = "Traefik Helm chart version"
  type        = string
  default     = "24.0.0"
}

variable "traefik_values" {
  description = "Additional values for Traefik Helm chart (in HCL format)"
  type        = any
  default     = {}
}

# Cert-Manager variables
variable "cert_manager_enabled" {
  description = "Whether to enable cert-manager for certificate automation"
  type        = bool
  default     = true
}

variable "cert_manager_chart_version" {
  description = "Cert-Manager Helm chart version"
  type        = string
  default     = "1.13.2"
}

variable "cert_manager_values" {
  description = "Additional values for cert-manager Helm chart (in HCL format)"
  type        = any
  default     = {}
}

# Let's Encrypt variables
variable "letsencrypt_enabled" {
  description = "Whether to enable Let's Encrypt certificate issuers"
  type        = bool
  default     = true
}

variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt notifications"
  type        = string
  default     = "admin@cherkaoui.ch"
}


# Monitoring variables
variable "monitoring_enabled" {
  description = "Whether to enable monitoring stack (Prometheus, Grafana, etc.)"
  type        = bool
  default     = true
}

variable "prometheus_chart_version" {
  description = "Prometheus Helm chart version"
  type        = string
  default     = "25.8.0"
}

variable "grafana_chart_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "7.0.19"
}

variable "monitoring_values" {
  description = "Additional values for monitoring Helm charts (in HCL format)"
  type        = any
  default     = {}
}

# KubeSphere variables
variable "kubesphere_enabled" {
  description = "Whether to enable KubeSphere dashboard"
  type        = bool
  default     = true
}

variable "kubesphere_version" {
  description = "KubeSphere version"
  type        = string
  default     = "v3.4.0"
}

# Digger variables
variable "digger_enabled" {
  description = "Whether to enable Digger (Terraform GitOps)"
  type        = bool
  default     = false
}

variable "digger_chart_version" {
  description = "Digger Helm chart version"
  type        = string
  default     = "0.3.0"
}

variable "digger_values" {
  description = "Additional values for Digger Helm chart (in HCL format)"
  type        = any
  default     = {}
}

# MetalLB variables
variable "metallb_enabled" {
  description = "Whether to enable MetalLB for load balancing"
  type        = bool
  default     = true
}

variable "metallb_chart_version" {
  description = "MetalLB Helm chart version"
  type        = string
  default     = "0.14.3"
}

variable "metallb_addresses" {
  description = "IP address range for MetalLB to use (e.g., ['192.168.1.240-192.168.1.250'])"
  type        = list(string)
  default     = ["192.168.1.240-192.168.1.250"]
}

variable "metallb_values" {
  description = "Additional values for MetalLB Helm chart (in HCL format)"
  type        = any
  default     = {}
}