# Websites Module

## Overview
This module deploys various websites and documentation platforms for your homelab Kubernetes cluster, including personal websites and documentation sites.

## Components
- **MkDocs Material**: Documentation site with material design
- **NGINX-based websites**: Personal websites for different users
- **Quillium Docs**: Documentation platform
- **Persistent Storage**: For website content and configuration
- **Ingress Configuration**: Traefik IngressRoutes for secure access

## Features
- Persistent storage for website content
- TLS encryption with Let's Encrypt
- Security headers for enhanced protection
- Multiple website deployments from a single module
- Custom domain support for each website

## Requirements
- Kubernetes cluster with Traefik ingress controller
- Let's Encrypt certificate resolver configured
- Persistent storage for website content

## Usage
Include this module in your OpenTofu configuration and provide the required variables:

```hcl
module "websites" {
  source = "./modules/websites"
  
  docs_hostname = "docs.yourdomain.com"
  hadi_hostname = "hadi.yourdomain.com"
  laura_hostname = "laura.yourdomain.com"
  quillium_docs_hostname = "quillium-docs.yourdomain.com"
}
```

## Content Management
Website content is stored in the persistent volume. To update content:

1. Access the persistent volume location on your Kubernetes node
2. Update the files in the appropriate subdirectory
3. The changes will be reflected immediately without redeploying

Alternatively, you can set up a CI/CD pipeline to update the content automatically.
