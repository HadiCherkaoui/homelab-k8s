# WireGuard Easy Module

## Overview
This module deploys WireGuard Easy, a simple web UI for managing WireGuard VPN connections in your homelab Kubernetes cluster.

## Components
- **WireGuard Easy**: Web-based WireGuard VPN management interface
- **Persistent Storage**: For WireGuard configuration and keys

## Features
- Web UI for managing WireGuard VPN connections
- Persistent storage for configuration (1Gi)
- Host network mode for direct port access
- Traffic statistics visualization
- Password protection for the web interface
- Custom DNS configuration

## Requirements
- Kubernetes cluster with storage provisioner
- Host that supports WireGuard kernel module
- Public IP or domain for remote VPN access

## Usage
Include this module in your OpenTofu configuration and provide the required variables:

```hcl
module "wg-easy" {
  source = "./modules/wg-easy"
  
  vpn_namespace = "vpn"
  wg_easy_hostname = "vpn.yourdomain.com"
  wg_easy_password_hash = "$2b$10$your-bcrypt-password-hash"
}
```

## Security Considerations
- The password hash should be generated using bcrypt
- WireGuard port (51820) is exposed directly through the host network
- Ensure your firewall allows traffic on the WireGuard port
- The module is configured to only allow traffic to private networks (10.0.0.0/8)

## Access
After deployment, the WireGuard Easy web interface will be accessible at the configured hostname on port 51821 (HTTPS). Use this interface to create and manage VPN clients.
