variable "media_namespace" {
  description = "Namespace where media apps are deployed"

  type    = string
  default = "media"
}

variable "plex_hostname" {
  description = "Hostname for Plex"
  type        = string
  default     = "plex.local.lab"
}

variable "notifiarr_apikey" {
  description = "Notifiarr API key"
  type        = string
  sensitive   = true
}

variable "openvpn_user" {
  type      = string
  sensitive = true
}

variable "openvpn_password" {
  type      = string
  sensitive = true
}

variable "openvpn_config" {
  type      = string
  sensitive = true
}

variable "plex_claim" {
  type      = string
  sensitive = true
}

variable "notifiarr_version" {
  type = string
}

variable "sonarr_version" {
  type = string
}

variable "qbittorrent_version" {
  type = string
}

variable "radarr_version" {
  type = string
}

variable "prowlarr_version" {
  type = string
}

variable "flaresolverr_version" {
  type = string
}

variable "overseerr_version" {
  type = string
}

variable "plex_version" {
  type = string
}