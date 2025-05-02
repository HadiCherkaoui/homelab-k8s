# Monitoring Module

## Overview
This module deploys a comprehensive monitoring stack for your homelab Kubernetes cluster using Prometheus and Grafana.

## Components
- **Prometheus**: Time series database for metrics collection and storage
- **Grafana**: Visualization and dashboarding platform
- **AlertManager**: Alerting and notification system
- **Node Exporter**: System metrics collection
- **Kube State Metrics**: Kubernetes cluster metrics collection
- **Ingress Configuration**: Traefik IngressRoute for secure Grafana access

## Features
- Persistent storage for Prometheus, AlertManager, and Grafana
- Pre-configured dashboards for Kubernetes and node monitoring
- Secure access to Grafana through Traefik ingress with TLS
- Resource limits to ensure stability in homelab environments
- 15-day metrics retention

## Requirements
- Kubernetes cluster with Traefik ingress controller
- Let's Encrypt certificate resolver configured
- Sufficient storage for metrics retention

## Usage
Include this module in your OpenTofu configuration and provide the required variables:

```hcl
module "monitoring" {
  source = "./modules/monitoring"
  
  monitoring_namespace = "monitoring"
  grafana_hostname = "grafana.yourdomain.com"
  grafana_admin_password = "your-secure-password"
  prometheus_storage = "10Gi"
  alertmanager_storage = "2Gi"
  grafana_storage = "2Gi"
}
```

## Access
After deployment, Grafana will be accessible at the configured hostname. The default admin username is "admin" with the password specified in your configuration.
