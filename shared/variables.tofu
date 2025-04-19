# Variables for provider configuration

variable "kube_config_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context to use from the kubeconfig file"
  type        = string
  default     = ""
}

# Variables for local storage configuration

variable "local_storage_path" {
  description = "Path to the local storage directory on the host"
  type        = string
  default     = "/mnt/k8s"
}

variable "local_storage_size" {
  description = "Size of the local storage volume"
  type        = string
  default     = "6000Gi"
}

variable "node_hostname" {
  description = "Hostname of the Kubernetes node where local storage is available"
  type        = string
  default     = "k8s-node"
}

variable "local_path_provisioner_namespace" {
  description = "Namespace where the Local Path Provisioner is deployed"
  type        = string
  default     = "ns-local-path-storage"
}