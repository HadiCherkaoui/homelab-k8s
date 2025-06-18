variable "rancher_namespace" {
  type    = string
  default = "rancher"
}

variable "rancher_hostname" {
  type = string
}

variable "rancher_bootstrap_password" {
  type      = string
  sensitive = true
}