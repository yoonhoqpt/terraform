locals {
  # verb variables
  glw = ["get", "list", "watch"]
  all = ["create", "get", "list", "watch", "patch", "delete"]

  # Mostly read access to check service health
  developer_rules = [{
    api_groups = [""]
    resources  = ["configmaps", "services"]
    verbs      = local.glw
    }, {
    api_groups = [""]
    resources  = ["namespaces", "serviceaccounts", "nodes", "resourcequotas"]
    verbs      = local.glw
    }, {
    api_groups = [""]
    resources  = ["pods", "pods/log"]
    verbs      = local.glw
    }, {
    api_groups = [""]
    resources  = ["events"]
    verbs      = local.glw
    }, {
    api_groups = ["apps"]
    resources  = ["deployments", "daemonsets", "statefulsets"]
    verbs      = local.glw
    }, {
    api_groups = [""]
    resources  = ["replicasets"]
    verbs      = local.glw
    }, {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = local.glw
    }, {
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
    verbs      = local.glw
    }, {
    api_groups = ["policy"]
    resources  = ["podsecuritypolicies"]
    verbs      = local.glw
    }, {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = local.glw
    }, {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = local.glw
    }, {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies"]
    verbs      = local.glw
    }, {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = local.glw
    }, {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "clusterroles", "rolebindings", "clusterrolebindings"]
    verbs      = local.glw
    }, {
    api_groups = ["settings.k8s.io"]
    resources  = ["podpresets"]
    verbs      = local.glw
    }, {
    api_groups = ["scheduling.k8s.io"]
    resources  = ["priorityclasses"]
    verbs      = local.glw
    }, {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = local.glw
    }, {
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
    verbs      = local.glw
    }, {
    api_groups = ["ops.dapperlabs.com"]
    resources  = ["wrappedsecrets"]
    verbs      = local.glw
    }
  ]

  # Develper with modify access to respond to incidents
  incident_responder_rules = concat(local.developer_rules, [{
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["delete"]
    }, {
    api_groups = [""]
    resources  = ["pods/portforward"]
    verbs      = ["create"]
    }, {
    api_groups = ["apps"]
    resources  = ["deployments", "deployments/scale"]
    verbs      = ["update", "patch"]
    }, {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["create"]
    }, {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs = ["create", "patch", "delete"] }
  ])

  # Developer, Incident Responder and additional deployment access
  deployer_rules = concat(
    # Developer + Incident Responder with all verbs
    [for rule in local.incident_responder_rules : {
      api_groups = rule.api_groups
      resources  = rule.resources
      verbs      = local.all
    }],
    # Deployer specific rules
    [{
      api_groups = [""]
      resources  = ["persistentvolumeclaims", "endpoints"]
      verbs      = local.all
      }
  ])

  # Wide access to modifying most cluster resources
  sre_rules = concat(local.deployer_rules, [{
    api_groups = [""]
    resources  = ["resourcequotas", "volumes", "nodes", "secrets", "replicasets"]
    verbs      = local.all
    }, {
    api_groups = ["policy"]
    resources  = ["podsecuritypolicies"]
    verbs      = local.all
    }, {
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies"]
    verbs      = local.all
    }, {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = local.all
    }, {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["clusterroles", "clusterrolebindings"]
    verbs      = local.all
    }, {
    api_groups = ["scheduling.k8s.io"]
    resources  = ["priorityclasses"]
    verbs      = local.all
    }, {
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
    verbs      = local.all
    }, {
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
    verbs      = local.all
    }
  ])

  # Role bindings
  developer_role_bindings = {
    backend = [
      "${var.product_name}-backend-service-developers@access.dapperlabs.com",
    ]
    frontend = [
      "${var.product_name}-frontend-application-developers@access.dapperlabs.com",
    ]
  }

  incident_responder_role_bindings = {
    backend = [
      "${var.product_name}-backend-service-developers@access.dapperlabs.com",
    ]
  }
}

# Application cluster roles and bindings

resource "kubernetes_cluster_role" "developer" {
  depends_on = [
    module.gke_application_cluster
  ]
  metadata {
    name = "developer"
  }

  dynamic "rule" {
    for_each = local.developer_rules
    content {
      api_groups = rule.value["api_groups"]
      resources  = rule.value["resources"]
      verbs      = rule.value["verbs"]
    }
  }
}

resource "kubernetes_cluster_role" "deployer" {
  depends_on = [
    module.gke_application_cluster
  ]
  metadata {
    name = "deployer"
  }

  dynamic "rule" {
    for_each = local.deployer_rules
    content {
      api_groups = rule.value["api_groups"]
      resources  = rule.value["resources"]
      verbs      = rule.value["verbs"]
    }
  }
}

resource "kubernetes_cluster_role" "incident-responder" {
  depends_on = [
    module.gke_application_cluster
  ]
  metadata {
    name = "incident-responder"
  }

  dynamic "rule" {
    for_each = local.incident_responder_rules
    content {
      api_groups = rule.value["api_groups"]
      resources  = rule.value["resources"]
      verbs      = rule.value["verbs"]
    }
  }
}

resource "kubernetes_role_binding" "deployers" {
  depends_on = [
    module.gke_application_cluster
  ]

  for_each = {
    backend  = module.backend_deployer_service_account.email
    frontend = module.frontend_deployer_service_account.email
  }

  metadata {
    name      = "deployers"
    namespace = each.key
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.deployer.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = each.value
    api_group = "rbac.authorization.k8s.io"
  }

}

# ⚠️ ATTENTION ⚠️
# When binding Roles to RBAC Groups make sure the group
# is a member of the gke-security-groups@dapperlabs.com Google Admin Group,
# otherwise kubectl requests from group members will be denied.
# IT can help with that.
# https://cloud.google.com/kubernetes-engine/docs/how-to/google-groups-rbac

resource "kubernetes_role_binding" "developers" {
  depends_on = [
    module.gke_application_cluster
  ]

  for_each = toset(keys(local.developer_role_bindings))

  metadata {
    name      = "developers"
    namespace = each.value
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.developer.metadata[0].name
  }

  dynamic "subject" {
    for_each = local.developer_role_bindings[each.value]
    content {
      kind      = "Group"
      name      = subject.value
      api_group = "rbac.authorization.k8s.io"
    }
  }
}

resource "kubernetes_role_binding" "incident_responders" {
  depends_on = [
    module.gke_application_cluster
  ]

  for_each = toset(keys(local.incident_responder_role_bindings))

  metadata {
    name      = "incident-responders"
    namespace = each.value
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.incident-responder.metadata[0].name
  }

  dynamic "subject" {
    for_each = local.incident_responder_role_bindings[each.value]
    content {
      kind      = "Group"
      name      = subject.value
      api_group = "rbac.authorization.k8s.io"
    }
  }
}
