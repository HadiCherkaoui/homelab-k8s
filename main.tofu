# /home/hadi/Documents/GitHub/homelab-k8s/main.tofu
module "shared_infra" {
  source = "./shared"

  # Pass the sensitive ACME email from the root variable definition
  acme_email                  = var.acme_email
  local_path_provisioner_path = var.local_path_provisioner_path
}

# Define the root variable needed by the module
variable "acme_email" {
  description = "Email address for ACME (Let's Encrypt) registration."
  type        = string
  sensitive   = true
  # This variable expects its value from tofu.tfvars or environment variables
}

variable "local_path_provisioner_path" {
  description = "Path on the node where local-path-provisioner will create PVs."
  type        = string
  # This variable expects its value from tofu.tfvars or environment variables
  default = "/mnt/k8s"
}

# Optional: Output the Traefik status from the module
output "traefik_service_status" {
  description = "Status of the Traefik LoadBalancer service from the shared module."
  value       = module.shared_infra.traefik_service_status
}