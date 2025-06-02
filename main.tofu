module "vpn" {
  source = "./modules/wg-easy"

  wg_easy_password_hash = var.wg_easy_password_hash
  wg_easy_hostname      = var.wg_easy_hostname
  wg_easy_version       = var.wg_easy_version
}

module "traefik" {
  source = "./modules/traefik"

  acme_email = var.acme_email
  traefik_version = var.traefik_version
}

module "storage" {
  source = "./modules/storage"

  local_path_provisioner_path = var.local_path_provisioner_path
}

module "websites" {
  source = "./modules/websites"

  hadi_hostname             = var.hadi_hostname
  laura_hostname            = var.laura_hostname
  quillium_docs_hostname    = var.quillium_docs_hostname
  quillium_webhook_hostname = var.quillium_webhook_hostname
  docs_hostname             = var.docs_hostname
}

module "monitoring" {
  source = "./modules/monitoring"

  grafana_hostname       = var.grafana_hostname
  grafana_admin_password = var.grafana_admin_password
  prometheus_retention   = var.prometheus_retention
  prometheus_storage     = var.prometheus_storage
  alertmanager_storage   = var.alertmanager_storage
  grafana_storage        = var.grafana_storage
  monitoring_version     = var.monitoring_version
}

module "media" {
  source = "./modules/media"

  openvpn_user     = var.openvpn_user
  openvpn_password = var.openvpn_password
  openvpn_config   = file("./.extra/ch-06.protonvpn.udp.ovpn")
  notifiarr_apikey = var.notifiarr_apikey
  plex_hostname    = var.plex_hostname
  plex_claim       = var.plex_claim
  notifiarr_version = var.notifiarr_version
  sonarr_version = var.sonarr_version
  qbittorrent_version = var.qbittorrent_version
  radarr_version = var.radarr_version
  prowlarr_version = var.prowlarr_version
  flaresolverr_version = var.flaresolverr_version
  overseerr_version = var.overseerr_version
  plex_version = var.plex_version
}

module "craftycontroller" {
  source = "./modules/craftycontroller"

  craftycontroller_version = var.craftycontroller_version
}

module "ai" {
  source = "./modules/ai"

  github_client_id     = var.github_client_id
  github_client_secret = var.github_client_secret

  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret

  microsoft_client_id     = var.microsoft_client_id
  microsoft_client_secret = var.microsoft_client_secret
  microsoft_tenant_id     = var.microsoft_tenant_id

  openwebui_hostname = var.openwebui_hostname
}

module "paperless" {
  source = "./modules/paperless"

  paperless_admin_user     = var.paperless_admin_user
  paperless_admin_password = var.paperless_admin_password
  paperless_admin_mail     = var.paperless_admin_mail
  paperless_hostname       = var.paperless_hostname
  paperless_version        = var.paperless_version
  cnpg_operator_version    = var.cnpg_operator_version
}