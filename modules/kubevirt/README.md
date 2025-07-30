# KubeVirt Module

This module deploys KubeVirt on your Kubernetes cluster, enabling you to run virtual machines alongside containers.

## Features

- **Complete KubeVirt Installation**: Deploys the KubeVirt operator, CRDs, and core components
- **Hardware Virtualization Support**: Optimized for bare metal nodes with KVM support
- **Software Emulation**: Optional fallback for environments without hardware virtualization
- **Resource Management**: Configurable CPU and memory limits for all components
- **Monitoring Integration**: Prometheus ServiceMonitor for metrics collection
- **Example Resources**: Pre-configured VM instance types and preferences
- **Security**: Follows security best practices with proper RBAC and security contexts

## Prerequisites

### Hardware Requirements
- Bare metal Kubernetes nodes with hardware virtualization support (Intel VT-x or AMD-V)
- KVM kernel modules loaded on nodes
- Sufficient CPU and memory resources for both containers and VMs

### Software Requirements
- Kubernetes cluster (1.24+)
- OpenTofu/Terraform with Kubernetes provider
- `virt-host-validate` tool for validation (optional but recommended)

### Verification Commands
Run these on your Kubernetes nodes to verify virtualization support:

```bash
# Check hardware virtualization support
virt-host-validate qemu

# Verify KVM modules are loaded
lsmod | grep kvm

# Check if /dev/kvm exists
ls -la /dev/kvm
```

## Usage

### Basic Configuration

```hcl
module "kubevirt" {
  source = "./modules/kubevirt"
  
  kubevirt_namespace = "kubevirt"
  kubevirt_version   = "v1.3.1"
}
```

### Advanced Configuration

```hcl
module "kubevirt" {
  source = "./modules/kubevirt"
  
  # Basic settings
  kubevirt_namespace = "virtualization"
  kubevirt_version   = "v1.3.1"
  
  # Enable software emulation for testing environments
  use_emulation = false
  
  # Monitoring
  enable_monitoring     = true
  monitoring_namespace  = "monitoring"
  
  # Example resources
  create_example_resources = true
  
  # Resource limits for virt-controller
  controller_cpu_request    = "200m"
  controller_cpu_limit      = "2000m"
  controller_memory_request = "256Mi"
  controller_memory_limit   = "1Gi"
  
  # Resource limits for virt-api
  api_cpu_request    = "200m"
  api_cpu_limit      = "2000m"
  api_memory_request = "256Mi"
  api_memory_limit   = "1Gi"
  
  # Resource limits for virt-handler
  handler_cpu_request    = "200m"
  handler_cpu_limit      = "2000m"
  handler_memory_request = "256Mi"
  handler_memory_limit   = "1Gi"
}
```

## Components Deployed

### Core Components
- **virt-operator**: Manages KubeVirt lifecycle and component deployments
- **virt-api**: Provides the KubeVirt API server
- **virt-controller**: Manages VM lifecycle and scheduling
- **virt-handler**: DaemonSet that runs on each node to manage VMs
- **virt-launcher**: Pod that wraps each VM instance

### RBAC Resources
- Service accounts with minimal required permissions
- Cluster roles for KubeVirt operations
- Role bindings for secure access

### Custom Resources
- KubeVirt CRD for configuration
- VirtualMachine and VirtualMachineInstance CRDs
- VirtualMachineInstancetype and VirtualMachinePreference CRDs

## Post-Installation

### 1. Verify Installation

```bash
# Check KubeVirt status
kubectl get kubevirt -n kubevirt

# Verify all pods are running
kubectl get pods -n kubevirt

# Check KubeVirt version
kubectl get kubevirt kubevirt -n kubevirt -o yaml
```

### 2. Install virtctl CLI Tool

```bash
# Get the KubeVirt version
VERSION=$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.observedKubeVirtVersion}")

# Download virtctl
ARCH=$(uname -s | tr 'A-Z' 'a-z')-$(uname -m | sed 's/x86_64/amd64/')
curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-${ARCH}

# Make executable and move to PATH
chmod +x virtctl
sudo mv virtctl /usr/local/bin/
```

### 3. Create Your First VM

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: testvm
  namespace: kubevirt
spec:
  running: false
  template:
    metadata:
      labels:
        kubevirt.io/size: small
        kubevirt.io/domain: testvm
    spec:
      instancetype:
        name: small
      preference:
        name: ubuntu
      domain:
        devices:
          disks:
          - name: containerdisk
            disk:
              bus: virtio
          - name: cloudinitdisk
            disk:
              bus: virtio
          interfaces:
          - name: default
            masquerade: {}
        resources:
          requests:
            memory: 2Gi
      networks:
      - name: default
        pod: {}
      volumes:
      - name: containerdisk
        containerDisk:
          image: quay.io/kubevirt/cirros-container-disk-demo
      - name: cloudinitdisk
        cloudInitNoCloud:
          userDataBase64: SGkuXG4=
```

### 4. VM Management Commands

```bash
# Start a VM
virtctl start testvm

# Stop a VM
virtctl stop testvm

# Get VM status
kubectl get vms

# Get VMI status
kubectl get vmis

# Connect to VM console
virtctl console testvm

# SSH into VM (if configured)
virtctl ssh user@testvm
```

## Troubleshooting

### Common Issues

1. **Pods stuck in Pending**: Check node resources and hardware virtualization support
2. **Permission denied errors**: Verify RBAC configurations and service account permissions
3. **VM fails to start**: Check if KVM modules are loaded and /dev/kvm is accessible
4. **Networking issues**: Ensure CNI plugin supports VM networking requirements

### Debug Commands

```bash
# Check KubeVirt events
kubectl get events -n kubevirt

# Check operator logs
kubectl logs -n kubevirt deployment/virt-operator

# Check API server logs
kubectl logs -n kubevirt deployment/virt-api

# Check controller logs
kubectl logs -n kubevirt deployment/virt-controller

# Check handler logs on specific node
kubectl logs -n kubevirt daemonset/virt-handler
```

### Hardware Validation

```bash
# Run on each Kubernetes node
virt-host-validate qemu

# Check KVM support
egrep -c '(vmx|svm)' /proc/cpuinfo

# Verify KVM modules
lsmod | grep kvm
```

## Security Considerations

- All components run with minimal required privileges
- Security contexts prevent privilege escalation
- RBAC follows principle of least privilege
- Container images are pulled from trusted registries
- Network policies can be applied to isolate VM traffic

## Monitoring

When monitoring is enabled, the module creates ServiceMonitor resources for Prometheus to scrape KubeVirt metrics:

- VM resource usage
- KubeVirt component health
- VM lifecycle events
- Performance metrics

## Variables

| Variable | Description | Type | Default |
|----------|-------------|------|---------|
| `kubevirt_namespace` | Namespace for KubeVirt resources | `string` | `"kubevirt"` |
| `kubevirt_version` | KubeVirt version to deploy | `string` | `"v1.3.1"` |
| `use_emulation` | Enable software emulation | `bool` | `false` |
| `enable_monitoring` | Enable Prometheus monitoring | `bool` | `true` |
| `monitoring_namespace` | Monitoring namespace | `string` | `"monitoring"` |
| `create_example_resources` | Create example resources | `bool` | `true` |
| `controller_cpu_request` | virt-controller CPU request | `string` | `"100m"` |
| `controller_cpu_limit` | virt-controller CPU limit | `string` | `"1000m"` |
| `controller_memory_request` | virt-controller memory request | `string` | `"150Mi"` |
| `controller_memory_limit` | virt-controller memory limit | `string` | `"512Mi"` |

## Outputs

| Output | Description |
|--------|-------------|
| `kubevirt_namespace` | KubeVirt namespace |
| `kubevirt_version` | Deployed KubeVirt version |
| `kubevirt_status` | KubeVirt deployment status |
| `example_instancetypes` | Created instance types |
| `example_preferences` | Created preferences |
| `monitoring_enabled` | Monitoring status |

## References

- [KubeVirt Documentation](https://kubevirt.io/user-guide/)
- [KubeVirt Installation Guide](https://kubevirt.io/user-guide/cluster_admin/installation/)
- [virtctl CLI Reference](https://kubevirt.io/user-guide/virtual_machines/virtctl_client_tool/)
- [VM Examples](https://github.com/kubevirt/demo)
