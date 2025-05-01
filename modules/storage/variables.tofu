variable "local_path_provisioner_path" {
  description = "Path on the node where local-path-provisioner will create PVs."
  type        = string
  default     = "/opt/local-path-provisioner"
}