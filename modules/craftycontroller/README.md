# Crafty Controller Module

## Overview
This module deploys Crafty Controller, a web-based management system for Minecraft servers in your homelab Kubernetes cluster.

## Components
- **Crafty Controller**: Web-based Minecraft server management interface
- **Persistent Storage**: For server files, backups, and configuration
- **Kubernetes Service**: Exposing web interface and Minecraft server ports

## Features
- Persistent storage for Minecraft server files (20Gi)
- Exposed ports:
  - 8443: Web interface
  - 25565: Minecraft server
  - 8123: Dynmap (Minecraft map visualization)
- Volume mounts for configuration, servers, logs, and backups

## Requirements
- Kubernetes cluster with storage provisioner
- Sufficient resources for running Minecraft servers

## Usage
Include this module in your OpenTofu configuration:

```hcl
module "craftycontroller" {
  source = "./modules/craftycontroller"
}
```

## Access
After deployment, the Crafty Controller web interface is available at port 8443 within your cluster. Configure an ingress or port forwarding to access it externally.
