variable "vpn_namespace" {
  description = "Namespace for VPN components"
  type        = string
  default     = "vpn"
}

variable "wg_easy_password_hash" {
  description = "Password hash for wg-easy"
  type        = string
  sensitive   = true
}

variable "wg_easy_hostname" {
  description = "Hostname for wg-easy"
  type        = string
}