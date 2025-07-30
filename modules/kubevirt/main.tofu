# KubeVirt Namespace
resource "kubernetes_namespace" "kubevirt" {
  metadata {
    name = "kubevirt"
  }
}

# KubeVirt Operator
resource "kubernetes_manifest" "kubevirt_operator" {
  depends_on = [kubernetes_namespace.kubevirt]

  manifest = {
    apiVersion = "apps/v1"
    kind       = "Deployment"
    metadata = {
      name      = "virt-operator"
      namespace = kubernetes_namespace.kubevirt.metadata[0].name
      labels = {
        "kubevirt.io" = ""
      }
    }
    spec = {
      replicas = 2
      selector = {
        matchLabels = {
          "kubevirt.io" = "virt-operator"
        }
      }
      template = {
        metadata = {
          labels = {
            "kubevirt.io" = "virt-operator"
          }
        }
        spec = {
          serviceAccountName = "kubevirt-operator"
          containers = [
            {
              name  = "virt-operator"
              image = "quay.io/kubevirt/virt-operator:v1.5.0"
              command = [
                "virt-operator",
                "--port", "8443",
                "-v", "2"
              ]
              ports = [
                {
                  containerPort = 8443
                  name          = "metrics"
                  protocol      = "TCP"
                }
              ]
              readinessProbe = {
                httpGet = {
                  path   = "/metrics"
                  port   = 8443
                  scheme = "HTTPS"
                }
                initialDelaySeconds = 5
                timeoutSeconds      = 10
              }
              env = [
                {
                  name  = "OPERATOR_IMAGE"
                  value = "quay.io/kubevirt/virt-operator:v1.5.0"
                },
                {
                  name = "WATCH_NAMESPACE"
                  valueFrom = {
                    fieldRef = {
                      fieldPath = "metadata.annotations['olm.targetNamespaces']"
                    }
                  }
                }
              ]
              resources = {
                requests = {
                  cpu    = "10m"
                  memory = "150Mi"
                }
              }
              securityContext = {
                allowPrivilegeEscalation = false
                capabilities = {
                  drop = ["ALL"]
                }
                runAsNonRoot = true
                seccompProfile = {
                  type = "RuntimeDefault"
                }
              }
            }
          ]
          nodeSelector = {
            "kubernetes.io/os" = "linux"
          }
          affinity = {
            podAntiAffinity = {
              preferredDuringSchedulingIgnoredDuringExecution = [
                {
                  weight = 1
                  podAffinityTerm = {
                    labelSelector = {
                      matchExpressions = [
                        {
                          key      = "kubevirt.io"
                          operator = "In"
                          values   = ["virt-operator"]
                        }
                      ]
                    }
                    topologyKey = "kubernetes.io/hostname"
                  }
                }
              ]
            }
          }
          tolerations = [
            {
              key      = "CriticalAddonsOnly"
              operator = "Exists"
            }
          ]
        }
      }
    }
  }
}

# KubeVirt Service Account
resource "kubernetes_service_account" "kubevirt_operator" {
  depends_on = [kubernetes_namespace.kubevirt]

  metadata {
    name      = "kubevirt-operator"
    namespace = kubernetes_namespace.kubevirt.metadata[0].name
    labels = {
      "kubevirt.io" = ""
    }
  }
}

# KubeVirt Cluster Role
resource "kubernetes_cluster_role" "kubevirt_operator" {
  metadata {
    name = "kubevirt.io:operator"
    labels = {
      "kubevirt.io" = ""
    }
  }

  rule {
    api_groups = ["kubevirt.io"]
    resources  = ["kubevirts"]
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts", "services", "endpoints", "pods/exec"]
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets"]
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["clusterroles", "clusterrolebindings", "roles", "rolebindings"]
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
  }

  rule {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
  }

  rule {
    api_groups = ["security.openshift.io"]
    resources  = ["securitycontextconstraints"]
    verbs      = ["create", "get", "list", "watch"]
  }

  rule {
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["validatingadmissionwebhooks", "mutatingadmissionwebhooks"]
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
  }

  rule {
    api_groups = ["apiregistration.k8s.io"]
    resources  = ["apiservices"]
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
  }

  rule {
    api_groups = ["monitoring.coreos.com"]
    resources  = ["servicemonitors", "prometheusrules"]
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch", "patch"]
  }

  rule {
    api_groups = ["flavor.kubevirt.io"]
    resources  = ["virtualmachineflavors", "virtualmachineclusterflavors"]
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
  }

  rule {
    api_groups = ["instancetype.kubevirt.io"]
    resources  = ["virtualmachineinstancetypes", "virtualmachineclusterinstancetypes"]
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
  }
}

# KubeVirt Cluster Role Binding
resource "kubernetes_cluster_role_binding" "kubevirt_operator" {
  depends_on = [
    kubernetes_service_account.kubevirt_operator,
    kubernetes_cluster_role.kubevirt_operator
  ]

  metadata {
    name = "kubevirt.io:operator"
    labels = {
      "kubevirt.io" = ""
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kubevirt_operator.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kubevirt_operator.metadata[0].name
    namespace = kubernetes_namespace.kubevirt.metadata[0].name
  }
}

# KubeVirt Custom Resource Definitions
resource "kubernetes_manifest" "kubevirt_crd" {
  depends_on = [kubernetes_namespace.kubevirt]

  manifest = {
    apiVersion = "apiextensions.k8s.io/v1"
    kind       = "CustomResourceDefinition"
    metadata = {
      name = "kubevirts.kubevirt.io"
      labels = {
        "kubevirt.io" = ""
      }
    }
    spec = {
      group = "kubevirt.io"
      names = {
        kind       = "KubeVirt"
        listKind   = "KubeVirtList"
        plural     = "kubevirts"
        singular   = "kubevirt"
        categories = ["all"]
      }
      scope = "Namespaced"
      versions = [
        {
          name    = "v1"
          served  = true
          storage = true
          schema = {
            openAPIV3Schema = {
              type = "object"
              properties = {
                spec = {
                  type = "object"
                  properties = {
                    certificateRotateStrategy = {
                      type = "object"
                    }
                    configuration = {
                      type = "object"
                    }
                    customizeComponents = {
                      type = "object"
                    }
                    imagePullPolicy = {
                      type = "string"
                    }
                    imageRegistry = {
                      type = "string"
                    }
                    imageTag = {
                      type = "string"
                    }
                    infra = {
                      type = "object"
                    }
                    monitorNamespace = {
                      type = "string"
                    }
                    productName = {
                      type = "string"
                    }
                    productVersion = {
                      type = "string"
                    }
                    uninstallStrategy = {
                      type = "string"
                    }
                    workloadUpdateStrategy = {
                      type = "object"
                    }
                  }
                }
                status = {
                  type = "object"
                  properties = {
                    conditions = {
                      type = "array"
                      items = {
                        type = "object"
                        properties = {
                          lastProbeTime = {
                            type = "string"
                          }
                          lastTransitionTime = {
                            type = "string"
                          }
                          message = {
                            type = "string"
                          }
                          reason = {
                            type = "string"
                          }
                          status = {
                            type = "string"
                          }
                          type = {
                            type = "string"
                          }
                        }
                        required = ["type", "status"]
                      }
                    }
                    defaultArchitecture = {
                      type = "string"
                    }
                    observedDeploymentConfig = {
                      type = "string"
                    }
                    observedDeploymentID = {
                      type = "string"
                    }
                    observedGeneration = {
                      type = "integer"
                    }
                    observedKubeVirtRegistry = {
                      type = "string"
                    }
                    observedKubeVirtVersion = {
                      type = "string"
                    }
                    operatorVersion = {
                      type = "string"
                    }
                    outdatedVirtualMachineInstanceWorkloads = {
                      type = "integer"
                    }
                    phase = {
                      type = "string"
                    }
                    targetDeploymentConfig = {
                      type = "string"
                    }
                    targetDeploymentID = {
                      type = "string"
                    }
                    targetKubeVirtRegistry = {
                      type = "string"
                    }
                    targetKubeVirtVersion = {
                      type = "string"
                    }
                  }
                }
              }
            }
          }
          subresources = {
            status = {}
          }
        }
      ]
    }
  }
}

# KubeVirt Custom Resource
resource "kubernetes_manifest" "kubevirt_cr" {
  depends_on = [
    kubernetes_manifest.kubevirt_operator,
    kubernetes_manifest.kubevirt_crd,
    kubernetes_cluster_role_binding.kubevirt_operator
  ]

  manifest = {
    apiVersion = "kubevirt.io/v1"
    kind       = "KubeVirt"
    metadata = {
      name      = "kubevirt"
      namespace = kubernetes_namespace.kubevirt.metadata[0].name
    }
    spec = {
      certificateRotateStrategy = {}
      configuration = {
        # Enable hardware virtualization features
        supportedGuestAgentVersions = [
          "6.1.0",
          "6.0.0",
          "5.6.0",
          "4.4.0"
        ]
      }
      customizeComponents = {
        patches = [
          {
            resourceName = "virt-controller"
            resourceType = "Deployment"
            patch = jsonencode({
              spec = {
                template = {
                  spec = {
                    containers = [
                      {
                        name = "virt-controller"
                      }
                    ]
                  }
                }
              }
            })
            type = "merge"
          },
          {
            resourceName = "virt-api"
            resourceType = "Deployment"
            patch = jsonencode({
              spec = {
                template = {
                  spec = {
                    containers = [
                      {
                        name = "virt-api"
                      }
                    ]
                  }
                }
              }
            })
            type = "merge"
          },
          {
            resourceName = "virt-handler"
            resourceType = "DaemonSet"
            patch = jsonencode({
              spec = {
                template = {
                  spec = {
                    containers = [
                      {
                        name = "virt-handler"
                      }
                    ]
                  }
                }
              }
            })
            type = "merge"
          }
        ]
      }
      imagePullPolicy = "IfNotPresent"
      imageRegistry   = "quay.io/kubevirt"
      imageTag        = "v1.5.0"
      workloadUpdateStrategy = {
        workloadUpdateMethods = ["LiveMigrate", "Evict"]
        batchEvictionSize     = 10
        batchEvictionInterval = "1m0s"
      }
    }
  }

  wait {
    condition {
      type   = "Available"
      status = "True"
    }
  }

  timeouts {
    create = "15m"
    update = "15m"
    delete = "5m"
  }
}

# KubeVirt Service Monitor for Prometheus
resource "kubernetes_manifest" "kubevirt_servicemonitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "kubevirt"
      namespace = kubernetes_namespace.kubevirt.metadata[0].name
      labels = {
        "kubevirt.io" = ""
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "kubevirt.io" = "virt-api"
        }
      }
      namespaceSelector = {
        matchNames = [kubernetes_namespace.kubevirt.metadata[0].name]
      }
      endpoints = [
        {
          port     = "metrics"
          path     = "/metrics"
          interval = "30s"
        }
      ]
    }
  }
}
