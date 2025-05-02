# Homelab Kubernetes Infrastructure

## Overview
This repository contains OpenTofu configurations for managing a homelab Kubernetes cluster. It provides a modular approach to deploying various services and applications in a self-hosted environment.

## Architecture
The infrastructure is designed around a single-node Kubernetes cluster with modular components that can be deployed independently. The configuration uses OpenTofu (not Terraform) with `.tofu` file extensions and OpenTofu registries.

## Modules

### Core Infrastructure
- **[Traefik](./modules/traefik/README.md)**: Ingress controller with automatic HTTPS and security features
- **[Monitoring](./modules/monitoring/README.md)**: Prometheus and Grafana stack for observability
- **[Storage](./modules/storage/README.md)**: Local path provisioner for persistent storage

### Applications
- **[AI](./modules/ai/README.md)**: Open WebUI for interacting with AI models
- **[Crafty Controller](./modules/craftycontroller/README.md)**: Minecraft server management
- **[Media](./modules/media/README.md)**: Complete media server stack (Plex, Sonarr, Radarr, etc.)
- **[Websites](./modules/websites/README.md)**: Personal websites and documentation platforms
- **[WireGuard Easy](./modules/wg-easy/README.md)**: VPN server with web UI

## Getting Started

### Prerequisites
- A Kubernetes cluster (single node or multi-node)
- OpenTofu installed on your local machine
- kubectl configured to access your cluster

### Deployment

1. Clone this repository:
   ```bash
   git clone https://github.com/HadiCherkaoui/homelab-k8s.git
   cd homelab-k8s
   ```

2. Create a `terraform.tfvars` file with your configuration values (see `variables.tofu` for required variables)

3. Initialize OpenTofu:
   ```bash
   tofu init
   ```

4. Apply the configuration:
   ```bash
   tofu apply
   ```

5. Format the code (as per user rules):
   ```bash
   tofu fmt -recursive
   ```

## Maintenance

### Updates
To update modules or components:

1. Modify the relevant `.tofu` files
2. Run `tofu plan` to review changes
3. Apply changes with `tofu apply`
4. Format the code with `tofu fmt -recursive`

### Backups
Persistent data is stored in volumes on the Kubernetes node. Ensure you have a backup strategy for these volumes.

## Contributing
Contributions are welcome! Please follow these guidelines:

1. Always format code using `tofu fmt -recursive`
2. Follow internet best practices for security
3. Use the latest version of modules/components
4. Update variables and output files in all modules

## License
This project is for personal use. Please respect the licenses of all included software components.