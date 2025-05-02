# Media Module

## Overview
This module deploys a comprehensive media server stack for your homelab Kubernetes cluster, including Plex, Sonarr, Radarr, and related services.

## Components
- **Plex**: Media server for organizing and streaming your media collection
- **Sonarr**: TV series management and automation
- **Radarr**: Movie management and automation
- **Prowlarr**: Indexer manager/proxy for Sonarr/Radarr
- **Overseerr**: Request management and media discovery
- **qBittorrent**: Download client with VPN integration
- **Notifiarr**: Notification service for your media stack
- **Service Monitoring**: Prometheus integration for monitoring

## Features
- Integrated media management ecosystem
- Automated content discovery and download
- Request management system
- Monitoring integration
- Secure access through Traefik ingress

## Requirements
- Kubernetes cluster with Traefik ingress controller
- Persistent storage for media files
- Prometheus monitoring stack (optional, for service monitoring)

## Usage
Include this module in your OpenTofu configuration and provide the required variables:

```hcl
module "media" {
  source = "./modules/media"
  
  # Configure hostnames and storage requirements
  plex_hostname = "plex.yourdomain.com"
  sonarr_hostname = "sonarr.yourdomain.com"
  radarr_hostname = "radarr.yourdomain.com"
  # Additional configuration variables as needed
}
```

## Note
This module is designed for personal, non-commercial use. Ensure you comply with all relevant laws and terms of service for the content you manage with this stack.
