resource "kubernetes_namespace" "kubevirt" {
  metadata {
    name = "kubevirt"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
      "openshift.io/cluster-monitoring"    = "true"
    }
  }
}

resource "kubernetes_priority_class" "kubevirt_cluster_critical" {
  metadata {
    name = "kubevirt-cluster-critical"
  }

  value       = 1000000000
  description = "This priority class should be used for core kubevirt components only."
}

resource "kubernetes_cluster_role" "kubevirt_io_operator" {
  metadata {
    name = "kubevirt.io:operator"

    labels = {
      "rbac.authorization.k8s.io/aggregate-to-admin" = "true"
    }
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch", "deletecollection"]
    api_groups = ["kubevirt.io"]
    resources  = ["kubevirts"]
  }
}

resource "kubernetes_service_account" "kubevirt_operator" {
  metadata {
    name      = "kubevirt-operator"
    namespace = "kubevirt"
  }
}

resource "kubernetes_role" "kubevirt_operator" {
  metadata {
    name      = "kubevirt-operator"
    namespace = "kubevirt"
  }

  rule {
    verbs          = ["create", "get", "list", "watch", "patch", "delete"]
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["kubevirt-ca", "kubevirt-export-ca", "kubevirt-virt-handler-certs", "kubevirt-virt-handler-server-certs", "kubevirt-operator-certs", "kubevirt-virt-api-certs", "kubevirt-controller-certs", "kubevirt-exportproxy-certs"]
  }

  rule {
    verbs      = ["create", "get", "list", "watch", "patch", "delete"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs      = ["create", "get", "list", "watch", "patch", "delete"]
    api_groups = ["route.openshift.io"]
    resources  = ["routes"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["route.openshift.io"]
    resources  = ["routes/custom-host"]
  }

  rule {
    verbs      = ["get", "list", "watch", "delete", "update", "create", "patch"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = ["route.openshift.io"]
    resources  = ["routes"]
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["get", "list", "watch", "delete", "update", "create", "patch"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs          = ["get", "list", "watch"]
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["kubevirt-export-ca"]
  }
}

resource "kubernetes_role_binding" "kubevirt_operator_rolebinding" {
  metadata {
    name      = "kubevirt-operator-rolebinding"
    namespace = "kubevirt"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "kubevirt-operator"
    namespace = "kubevirt"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "kubevirt-operator"
  }
}

resource "kubernetes_cluster_role" "kubevirt_operator" {
  metadata {
    name = "kubevirt-operator"
  }

  rule {
    verbs      = ["get", "list", "watch", "patch", "update", "patch"]
    api_groups = ["kubevirt.io"]
    resources  = ["kubevirts"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "delete", "patch"]
    api_groups = [""]
    resources  = ["serviceaccounts", "services", "endpoints", "pods/exec"]
  }

  rule {
    verbs      = ["patch", "delete"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "delete", "patch"]
    api_groups = ["batch"]
    resources  = ["jobs"]
  }

  rule {
    verbs      = ["watch", "list", "create", "delete", "patch"]
    api_groups = ["apps"]
    resources  = ["controllerrevisions"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "delete", "patch"]
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["clusterroles", "clusterrolebindings", "roles", "rolebindings"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "delete", "patch"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs      = ["create", "get", "list", "watch"]
    api_groups = ["security.openshift.io"]
    resources  = ["securitycontextconstraints"]
  }

  rule {
    verbs          = ["get", "patch", "update"]
    api_groups     = ["security.openshift.io"]
    resources      = ["securitycontextconstraints"]
    resource_names = ["privileged"]
  }

  rule {
    verbs          = ["get", "list", "watch", "update", "delete"]
    api_groups     = ["security.openshift.io"]
    resources      = ["securitycontextconstraints"]
    resource_names = ["kubevirt-handler", "kubevirt-controller"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "delete", "update", "patch"]
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["validatingwebhookconfigurations", "mutatingwebhookconfigurations", "validatingadmissionpolicybindings", "validatingadmissionpolicies"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "delete", "update", "patch"]
    api_groups = ["apiregistration.k8s.io"]
    resources  = ["apiservices"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "delete", "update", "patch"]
    api_groups = ["monitoring.coreos.com"]
    resources  = ["servicemonitors", "prometheusrules"]
  }

  rule {
    verbs      = ["get", "list", "watch", "patch"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["get", "list", "delete", "patch"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["get", "list", "watch", "patch", "update"]
    api_groups = ["kubevirt.io"]
    resources  = ["virtualmachines", "virtualmachineinstances"]
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
  }

  rule {
    verbs      = ["patch"]
    api_groups = ["kubevirt.io"]
    resources  = ["virtualmachines/status"]
  }

  rule {
    verbs      = ["create", "get", "list", "watch", "patch"]
    api_groups = ["kubevirt.io"]
    resources  = ["virtualmachineinstancemigrations"]
  }

  rule {
    verbs      = ["watch", "list"]
    api_groups = ["kubevirt.io"]
    resources  = ["virtualmachineinstancepresets"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs      = ["watch", "list"]
    api_groups = [""]
    resources  = ["limitranges"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["kubevirt.io"]
    resources  = ["kubevirts"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["snapshot.kubevirt.io"]
    resources  = ["virtualmachinesnapshots", "virtualmachinerestores", "virtualmachinesnapshotcontents"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["cdi.kubevirt.io"]
    resources  = ["datasources", "datavolumes"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["instancetype.kubevirt.io"]
    resources  = ["virtualmachineinstancetypes", "virtualmachineclusterinstancetypes", "virtualmachinepreferences", "virtualmachineclusterpreferences"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["migrations.kubevirt.io"]
    resources  = ["migrationpolicies"]
  }

  rule {
    verbs      = ["create", "list", "get"]
    api_groups = ["apps"]
    resources  = ["controllerrevisions"]
  }

  rule {
    verbs      = ["get", "list", "watch", "patch"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["get", "list", "watch", "delete", "create", "patch"]
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
  }

  rule {
    verbs      = ["get", "list", "watch", "delete", "update", "create", "patch"]
    api_groups = [""]
    resources  = ["pods", "configmaps", "endpoints", "services"]
  }

  rule {
    verbs      = ["update", "create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["update"]
    api_groups = [""]
    resources  = ["pods/finalizers"]
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["pods/eviction"]
  }

  rule {
    verbs      = ["patch"]
    api_groups = [""]
    resources  = ["pods/status"]
  }

  rule {
    verbs      = ["get", "list", "watch", "update", "patch"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["list"]
    api_groups = ["apps"]
    resources  = ["daemonsets"]
  }

  rule {
    verbs      = ["watch", "list", "create", "delete", "get", "update"]
    api_groups = ["apps"]
    resources  = ["controllerrevisions"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "delete", "patch"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "delete", "patch"]
    api_groups = ["snapshot.kubevirt.io"]
    resources  = ["virtualmachinesnapshots", "virtualmachinesnapshots/status", "virtualmachinesnapshots/finalizers", "virtualmachinesnapshotcontents", "virtualmachinesnapshotcontents/status", "virtualmachinesnapshotcontents/finalizers", "virtualmachinerestores", "virtualmachinerestores/status"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "delete", "patch"]
    api_groups = ["export.kubevirt.io"]
    resources  = ["virtualmachineexports", "virtualmachineexports/status", "virtualmachineexports/finalizers"]
  }

  rule {
    verbs      = ["watch", "list", "create", "delete", "update", "patch", "get"]
    api_groups = ["pool.kubevirt.io"]
    resources  = ["virtualmachinepools", "virtualmachinepools/finalizers", "virtualmachinepools/status", "virtualmachinepools/scale"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["kubevirt.io"]
    resources  = ["*"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["kubevirt.io"]
    resources  = ["virtualmachines/finalizers", "virtualmachineinstances/finalizers"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["virtualmachines/stop", "virtualmachineinstances/addvolume", "virtualmachineinstances/removevolume", "virtualmachineinstances/freeze", "virtualmachineinstances/unfreeze", "virtualmachineinstances/reset", "virtualmachineinstances/softreboot", "virtualmachineinstances/sev/setupsession", "virtualmachineinstances/sev/injectlaunchsecret"]
  }

  rule {
    verbs      = ["*"]
    api_groups = ["cdi.kubevirt.io"]
    resources  = ["*"]
  }

  rule {
    verbs      = ["get"]
    api_groups = ["k8s.cni.cncf.io"]
    resources  = ["network-attachment-definitions"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["authorization.k8s.io"]
    resources  = ["subjectaccessreviews"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshotclasses"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
    api_groups = ["snapshot.storage.k8s.io"]
    resources  = ["volumesnapshots"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["instancetype.kubevirt.io"]
    resources  = ["virtualmachineinstancetypes", "virtualmachineclusterinstancetypes", "virtualmachinepreferences", "virtualmachineclusterpreferences"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["migrations.kubevirt.io"]
    resources  = ["migrationpolicies"]
  }

  rule {
    verbs      = ["get", "list", "watch", "update", "patch", "delete"]
    api_groups = ["clone.kubevirt.io"]
    resources  = ["virtualmachineclones", "virtualmachineclones/status", "virtualmachineclones/finalizers"]
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["resourcequotas"]
  }

  rule {
    verbs      = ["create", "get", "delete"]
    api_groups = ["batch"]
    resources  = ["jobs"]
  }

  rule {
    verbs      = ["update", "list", "watch"]
    api_groups = ["kubevirt.io"]
    resources  = ["virtualmachineinstances"]
  }

  rule {
    verbs      = ["patch", "list", "watch", "get"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["kubevirt.io"]
    resources  = ["kubevirts"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["migrations.kubevirt.io"]
    resources  = ["migrationpolicies"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["export.kubevirt.io"]
    resources  = ["virtualmachineexports"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["kubevirt.io"]
    resources  = ["kubevirts"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = ["kubevirt.io"]
    resources  = ["kubevirts"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["version", "guestfs"]
  }

  rule {
    verbs      = ["get"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["virtualmachineinstances/console", "virtualmachineinstances/vnc", "virtualmachineinstances/vnc/screenshot", "virtualmachineinstances/portforward", "virtualmachineinstances/guestosinfo", "virtualmachineinstances/filesystemlist", "virtualmachineinstances/userlist", "virtualmachineinstances/sev/fetchcertchain", "virtualmachineinstances/sev/querylaunchmeasurement", "virtualmachineinstances/usbredir"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["virtualmachineinstances/pause", "virtualmachineinstances/unpause", "virtualmachineinstances/addvolume", "virtualmachineinstances/removevolume", "virtualmachineinstances/freeze", "virtualmachineinstances/unfreeze", "virtualmachineinstances/softreboot", "virtualmachineinstances/reset", "virtualmachineinstances/sev/setupsession", "virtualmachineinstances/sev/injectlaunchsecret"]
  }

  rule {
    verbs      = ["get"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["virtualmachines/expand-spec", "virtualmachines/portforward"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["virtualmachines/start", "virtualmachines/stop", "virtualmachines/restart", "virtualmachines/addvolume", "virtualmachines/removevolume", "virtualmachines/memorydump"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["expand-vm-spec"]
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch", "deletecollection"]
    api_groups = ["kubevirt.io"]
    resources  = ["virtualmachines", "virtualmachineinstances", "virtualmachineinstancepresets", "virtualmachineinstancereplicasets"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["kubevirt.io"]
    resources  = ["virtualmachineinstancemigrations"]
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch", "deletecollection"]
    api_groups = ["snapshot.kubevirt.io"]
    resources  = ["virtualmachinesnapshots", "virtualmachinesnapshotcontents", "virtualmachinerestores"]
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch", "deletecollection"]
    api_groups = ["export.kubevirt.io"]
    resources  = ["virtualmachineexports"]
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch", "deletecollection"]
    api_groups = ["clone.kubevirt.io"]
    resources  = ["virtualmachineclones"]
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch", "deletecollection"]
    api_groups = ["instancetype.kubevirt.io"]
    resources  = ["virtualmachineinstancetypes", "virtualmachineclusterinstancetypes", "virtualmachinepreferences", "virtualmachineclusterpreferences"]
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch", "deletecollection"]
    api_groups = ["pool.kubevirt.io"]
    resources  = ["virtualmachinepools"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["migrations.kubevirt.io"]
    resources  = ["migrationpolicies"]
  }

  rule {
    verbs      = ["get"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["virtualmachineinstances/console", "virtualmachineinstances/vnc", "virtualmachineinstances/vnc/screenshot", "virtualmachineinstances/portforward", "virtualmachineinstances/guestosinfo", "virtualmachineinstances/filesystemlist", "virtualmachineinstances/userlist", "virtualmachineinstances/sev/fetchcertchain", "virtualmachineinstances/sev/querylaunchmeasurement", "virtualmachineinstances/usbredir"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["virtualmachineinstances/pause", "virtualmachineinstances/unpause", "virtualmachineinstances/addvolume", "virtualmachineinstances/removevolume", "virtualmachineinstances/freeze", "virtualmachineinstances/unfreeze", "virtualmachineinstances/softreboot", "virtualmachineinstances/reset", "virtualmachineinstances/sev/setupsession", "virtualmachineinstances/sev/injectlaunchsecret"]
  }

  rule {
    verbs      = ["get"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["virtualmachines/expand-spec", "virtualmachines/portforward"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["virtualmachines/start", "virtualmachines/stop", "virtualmachines/restart", "virtualmachines/addvolume", "virtualmachines/removevolume", "virtualmachines/memorydump"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["expand-vm-spec"]
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
    api_groups = ["kubevirt.io"]
    resources  = ["virtualmachines", "virtualmachineinstances", "virtualmachineinstancepresets", "virtualmachineinstancereplicasets"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["kubevirt.io"]
    resources  = ["virtualmachineinstancemigrations"]
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
    api_groups = ["snapshot.kubevirt.io"]
    resources  = ["virtualmachinesnapshots", "virtualmachinesnapshotcontents", "virtualmachinerestores"]
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
    api_groups = ["export.kubevirt.io"]
    resources  = ["virtualmachineexports"]
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
    api_groups = ["clone.kubevirt.io"]
    resources  = ["virtualmachineclones"]
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
    api_groups = ["instancetype.kubevirt.io"]
    resources  = ["virtualmachineinstancetypes", "virtualmachineclusterinstancetypes", "virtualmachinepreferences", "virtualmachineclusterpreferences"]
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch"]
    api_groups = ["pool.kubevirt.io"]
    resources  = ["virtualmachinepools"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = ["kubevirt.io"]
    resources  = ["kubevirts"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["migrations.kubevirt.io"]
    resources  = ["migrationpolicies"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = ["kubevirt.io"]
    resources  = ["kubevirts"]
  }

  rule {
    verbs      = ["get"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["virtualmachines/expand-spec", "virtualmachineinstances/guestosinfo", "virtualmachineinstances/filesystemlist", "virtualmachineinstances/userlist", "virtualmachineinstances/sev/fetchcertchain", "virtualmachineinstances/sev/querylaunchmeasurement"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["expand-vm-spec"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["kubevirt.io"]
    resources  = ["virtualmachines", "virtualmachineinstances", "virtualmachineinstancepresets", "virtualmachineinstancereplicasets", "virtualmachineinstancemigrations"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["snapshot.kubevirt.io"]
    resources  = ["virtualmachinesnapshots", "virtualmachinesnapshotcontents", "virtualmachinerestores"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["export.kubevirt.io"]
    resources  = ["virtualmachineexports"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["clone.kubevirt.io"]
    resources  = ["virtualmachineclones"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["instancetype.kubevirt.io"]
    resources  = ["virtualmachineinstancetypes", "virtualmachineclusterinstancetypes", "virtualmachinepreferences", "virtualmachineclusterpreferences"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["pool.kubevirt.io"]
    resources  = ["virtualmachinepools"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["migrations.kubevirt.io"]
    resources  = ["migrationpolicies"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["instancetype.kubevirt.io"]
    resources  = ["virtualmachineclusterinstancetypes", "virtualmachineclusterpreferences"]
  }

  rule {
    verbs      = ["update"]
    api_groups = ["subresources.kubevirt.io"]
    resources  = ["virtualmachines/migrate"]
  }

  rule {
    verbs      = ["get", "delete", "create", "update", "patch", "list", "watch", "deletecollection"]
    api_groups = ["kubevirt.io"]
    resources  = ["virtualmachineinstancemigrations"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["authentication.k8s.io"]
    resources  = ["tokenreviews"]
  }

  rule {
    verbs      = ["create"]
    api_groups = ["authorization.k8s.io"]
    resources  = ["subjectaccessreviews"]
  }
}

resource "kubernetes_cluster_role_binding" "kubevirt_operator" {
  metadata {
    name = "kubevirt-operator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "kubevirt-operator"
    namespace = "kubevirt"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "kubevirt-operator"
  }
}

resource "kubernetes_deployment" "virt_operator" {
  metadata {
    name      = "virt-operator"
    namespace = "kubevirt"

    labels = {
      "kubevirt.io" = "virt-operator"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        "kubevirt.io" = "virt-operator"
      }
    }

    template {
      metadata {
        name = "virt-operator"

        labels = {
          "kubevirt.io"            = "virt-operator"
          name                     = "virt-operator"
          "prometheus.kubevirt.io" = "true"
        }

        annotations = {
          "openshift.io/required-scc" = "restricted-v2"
        }
      }

      spec {
        volume {
          name = "kubevirt-operator-certs"

          secret {
            secret_name = "kubevirt-operator-certs"
            optional    = true
          }
        }

        volume {
          name = "profile-data"
          empty_dir {}
        }

        container {
          name    = "virt-operator"
          image   = "quay.io/kubevirt/virt-operator:v1.5.2"
          command = ["virt-operator"]
          args    = ["--port", "8443", "-v", "2"]

          port {
            name           = "metrics"
            container_port = 8443
            protocol       = "TCP"
          }

          port {
            name           = "webhooks"
            container_port = 8444
            protocol       = "TCP"
          }

          env {
            name  = "VIRT_OPERATOR_IMAGE"
            value = "quay.io/kubevirt/virt-operator:v1.5.2"
          }

          env {
            name = "WATCH_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.annotations['olm.targetNamespaces']"
              }
            }
          }

          env {
            name  = "KUBEVIRT_VERSION"
            value = "v1.5.2"
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "450Mi"
            }
          }

          volume_mount {
            name       = "kubevirt-operator-certs"
            read_only  = true
            mount_path = "/etc/virt-operator/certificates"
          }

          volume_mount {
            name       = "profile-data"
            mount_path = "/profile-data"
          }

          readiness_probe {
            http_get {
              path   = "/metrics"
              port   = "8443"
              scheme = "HTTPS"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 10
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "kubevirt-operator"

        security_context {
          run_as_non_root = true

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 1

              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "kubevirt.io"
                    operator = "In"
                    values   = ["virt-operator"]
                  }
                }

                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        toleration {
          key      = "CriticalAddonsOnly"
          operator = "Exists"
        }

        priority_class_name = "kubevirt-cluster-critical"
      }
    }

    strategy {
      type = "RollingUpdate"
    }
  }
}

resource "kubernetes_manifest" "kubevirt" {
  manifest = {
    apiVersion = "kubevirt.io/v1"
    kind       = "KubeVirt"
    metadata = {
      name      = "kubevirt"
      namespace = "kubevirt"
    }
    spec = {
      certificateRotateStrategy = {}
      configuration = {
        developerConfiguration = {
          featureGates = []
        }
      }
      customizeComponents    = {}
      imagePullPolicy        = "IfNotPresent"
      workloadUpdateStrategy = {}
    }
  }
}

resource "kubernetes_manifest" "kubevirt_operator_crd" {
  manifest = yamldecode(file("${path.module}/kubevirt-operator-crd.yaml"))
}