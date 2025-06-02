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

variable "paperless_namespace" {
  type    = string
  default = "paperless"
}

variable "paperless_version" {
  type = string
}

variable "cnpg_operator_version" {
  type = string
}