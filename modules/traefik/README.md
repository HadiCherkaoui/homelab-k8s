# Traefik Module

## Overview
This module deploys Traefik as the ingress controller for your homelab Kubernetes cluster, providing routing, TLS termination, and security features.

## Components
- **Traefik**: Modern HTTP reverse proxy and load balancer
- **Security Headers Middleware**: Default security headers for all services
- **Prometheus ServiceMonitor**: Integration with the monitoring stack

## Features
- Automatic HTTPS with Let's Encrypt integration
- HTTP to HTTPS redirection
- Persistent storage for TLS certificates
- Cross-namespace service discovery
- Security headers for enhanced protection
- Metrics exposure for Prometheus monitoring
- Host network mode for direct port binding

## Requirements
- Kubernetes cluster
- Valid email address for Let's Encrypt
- Monitoring namespace with Prometheus operator (for ServiceMonitor)

## Usage
Include this module in your OpenTofu configuration and provide the required variables:

```hcl
module "traefik" {
  source = "./modules/traefik"
  
  traefik_namespace = "traefik"
  acme_email = "your-email@example.com"
}
```

## Security
This module configures Traefik with security best practices:
- TLS for all services with automatic certificate management
- Security headers including Content-Security-Policy, X-Frame-Options, and more
- HTTP to HTTPS redirection for all traffic

## Monitoring
Traefik metrics are exposed and configured for scraping by Prometheus through a ServiceMonitor, allowing you to monitor traffic patterns and performance.
