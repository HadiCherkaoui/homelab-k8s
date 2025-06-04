# GitLab Module for Homelab Kubernetes

## Overview
This module deploys GitLab on a Kubernetes cluster using the official Helm chart. It includes the GitLab application, container registry, and the GitLab agent for Kubernetes integration.

## Features
- Complete GitLab instance with web UI, container registry, and Minio for object storage
- GitLab Kubernetes Agent for GitOps workflows
- Prometheus monitoring integration
- Custom domain and hostname configuration

## Prerequisites
- Kubernetes cluster with Helm configured
- Ingress controller (like Traefik) already deployed
- Persistent storage provisioner

## Configuration

### Required Variables

| Variable | Description |
|----------|-------------|
| `gitlab_domain` | Base domain for GitLab services |
| `gitlab_hostname` | Hostname for the main GitLab UI |
| `gitlab_registry_hostname` | Hostname for the container registry |
| `gitlab_minio_hostname` | Hostname for Minio object storage |
| `gitlab_kas_hostname` | Hostname for Kubernetes agent server |
| `gitlab_version` | Version of GitLab Helm chart to deploy |
| `gitlab_agent_version` | Version of GitLab agent Helm chart to deploy |

## Usage

```hcl
module "gitlab" {
  source = "./modules/gitlab"
  
  gitlab_domain = "example.com"
  gitlab_hostname = "gitlab.example.com"
  gitlab_registry_hostname = "registry.example.com"
  gitlab_minio_hostname = "minio.gitlab.example.com"
  gitlab_kas_hostname = "kas.gitlab.example.com"
  gitlab_version = "7.0.1"
  gitlab_agent_version = "1.16.0"
}
```

## Architecture
The module deploys GitLab in its own namespace with the following components:
- GitLab web UI
- Container Registry
- Minio for object storage
- GitLab Kubernetes Agent Server (KAS)

The module disables the built-in ingress controller and cert-manager, assuming you're using your own ingress solution.

## Maintenance

### Upgrading
To upgrade GitLab to a newer version:

1. Update the `gitlab_version` variable
2. Run `tofu plan` to review changes
3. Apply with `tofu apply`

### Backups
GitLab data is stored in persistent volumes. Ensure you have a backup strategy for these volumes.

## Troubleshooting

### Common Issues
- If GitLab fails to start, check the pod logs: `kubectl logs -n gitlab <pod-name>`
- For registry issues, verify the registry hostname is correctly configured in DNS
- For performance issues, consider increasing resource limits in your values configuration