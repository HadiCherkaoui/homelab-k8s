# AI Module

## Overview
This module deploys Open WebUI, a user-friendly interface for interacting with AI models in your homelab Kubernetes cluster.

## Components
- **OpenWebUI**: A web interface for AI models with SSO integration
- **Ingress Configuration**: Traefik IngressRoute for secure access

## Features
- Single Sign-On (SSO) integration with multiple providers:
  - GitHub
  - Google
  - Microsoft
- TLS encryption with Let's Encrypt
- Security headers for enhanced protection

## Requirements
- Kubernetes cluster with Traefik ingress controller
- Let's Encrypt certificate resolver configured
- Valid SSO credentials for the configured providers

## Usage
Include this module in your OpenTofu configuration and provide the required variables for SSO integration and hostname configuration.

```hcl
module "ai" {
  source = "./modules/ai"
  
  openwebui_hostname    = "ai.yourdomain.com"
  github_client_id      = "your-github-client-id"
  github_client_secret  = "your-github-client-secret"
  google_client_id      = "your-google-client-id"
  google_client_secret  = "your-google-client-secret"
  microsoft_client_id   = "your-microsoft-client-id"
  microsoft_client_secret = "your-microsoft-client-secret"
  microsoft_tenant_id   = "your-microsoft-tenant-id"
}
```
