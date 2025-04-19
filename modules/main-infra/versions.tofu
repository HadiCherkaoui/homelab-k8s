# OpenTofu and provider versions for main infrastructure module

# Import shared versions
module "shared_versions" {
  source = "../../shared"
}

# Local versions specific to this module
locals {
  # Chart versions
  traefik_chart_version      = var.traefik_chart_version
  prometheus_chart_version   = var.prometheus_chart_version
  grafana_chart_version      = var.grafana_chart_version
  digger_chart_version       = var.digger_chart_version
  cert_manager_chart_version = var.cert_manager_chart_version
  metallb_chart_version      = var.metallb_chart_version

  # Application versions
  kubesphere_version = var.kubesphere_version
}