# Storage Module

## Overview
This module deploys the Local Path Provisioner for your homelab Kubernetes cluster, providing a simple way to use local storage in your nodes.

## Components
- **Local Path Provisioner**: A storage provisioner that utilizes local disk space on Kubernetes nodes

## Features
- Sets up a default StorageClass for dynamic provisioning
- Configurable storage paths on nodes
- Specifically configured for homelab environments
- Works with single or multi-node clusters

## Requirements
- Kubernetes cluster
- Sufficient disk space on the node(s) at the configured path

## Usage
Include this module in your OpenTofu configuration and provide the path where you want to store the persistent volumes:

```hcl
module "storage" {
  source = "./modules/storage"
  
  local_path_provisioner_path = "/opt/local-path-provisioner"
}
```

## How It Works
The Local Path Provisioner creates PersistentVolumes using hostPath for PersistentVolumeClaims. This means that data is stored directly on the node's filesystem at the configured path. This is suitable for homelab environments but doesn't provide data replication or migration between nodes in a multi-node cluster scenario.
