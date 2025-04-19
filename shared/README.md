# Shared OpenTofu Configuration

This directory contains shared configuration files that can be reused across multiple OpenTofu modules in the homelab Kubernetes project.

## Files

- `providers.tofu` - Contains the provider configurations for Kubernetes, Helm, and Kubectl
- `variables.tofu` - Defines common variables used by the providers

## Usage

To use these shared configurations in other modules, you can reference them using the OpenTofu module system. For example:

```hcl
module "shared" {
  source = "../shared"
}
```

Note that OpenTofu uses `.tofu` file extensions instead of the traditional `.tf` extensions used by Terraform. OpenTofu also uses its own provider registry (`opentofu/*`) instead of the HashiCorp registry.

Or you can include these files directly in your module using symbolic links or by copying them.

## Variables

| Name | Description | Default |
|------|-------------|--------|
| `kube_config_path` | Path to the kubeconfig file | `~/.kube/config` |
| `kube_context` | Kubernetes context to use from the kubeconfig file | `""` (empty string) |
