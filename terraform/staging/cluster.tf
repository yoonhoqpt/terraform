locals {
  nodepools = {
    "frontend-standard-8" = {
      node_machine_type = "e2-standard-8"
      min_node_count    = 1
      max_node_count    = 3
      node_labels = {
        "ops.dapperlabs.com/preferred-namespace" : "frontend"
      }
    }
    "backend-standard-8" = {
      node_machine_type = "e2-standard-8"
      min_node_count    = 1
      max_node_count    = 3
      node_labels = {
        "ops.dapperlabs.com/preferred-namespace" : "backend"
      }
    }
    "sre-standard-8" = {
      node_machine_type = "e2-standard-8"
      min_node_count    = 1
      max_node_count    = 3
      node_labels = {
        "ops.dapperlabs.com/preferred-namespace" : "sre"
      }
    }
  }
}

# Application cluster
module "gke_application_cluster" {
  source = "github.com/dapperlabs-platform/terraform-google-gke-cluster?ref=v0.9.12"

  project_id = module.project.project_id
  name       = "${var.default_region}-application"
  # STABLE for production
  release_channel              = "REGULAR"
  location                     = var.default_region
  network                      = module.gke_vpc.self_link
  subnetwork                   = module.gke_vpc.subnet_self_links["${var.default_region}/gke"]
  secondary_range_pods         = "pods"
  secondary_range_services     = "services"
  default_max_pods_per_node    = 100
  authenticator_security_group = "gke-security-groups@dapperlabs.com"

  addons = {
    gce_persistent_disk_csi_driver_config = true
  }

  # remove for production
  node_locations = [
    "us-west1-a"
  ]

  master_authorized_ranges = merge(
    local.perimeter_81_ips,
    local.atlantis_ips,
  )
  private_cluster_config = {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "10.0.16.0/28"
    master_global_access    = false
  }
  labels = {
    environment = var.environment
  }

  namespaces = [
    "sre",
    "backend",
    "frontend",
    "kyverno",
    "policy-reporter"
  ]

  workload_identity_profiles = {
    "sre" = [for v in [
      "sre-operator@dapper-ops.iam.gserviceaccount.com",
      # Cannot reference module.service-account.email here because
      # the "for_each" value depends on resource attributes that cannot be determined
      # until apply, so Terraform cannot predict how many instances will be created.
      # "<service-account-name>@${var.project_name}.iam.gserviceaccount.com"
      ] : { email : v
      automount_service_account_token = true }
    ]
    "backend" = [for v in [
      "kms-signer@${var.project_name}.iam.gserviceaccount.com",
      "flow-pds@${var.project_name}.iam.gserviceaccount.com"
      ] : { email : v }
    ]
    "cert-manager" = [
      # TODO: Uncomment if using private CA module
      #{
      #  email                           = module.temporal-private-ca.sa_email
      #  automount_service_account_token = true
      #}
    ]

  }
}

module "gke_application_cluster-nodepools" {
  depends_on = [
    module.gke_workload_runner
  ]
  for_each                    = local.nodepools
  source                      = "github.com/dapperlabs-platform/terraform-google-gke-nodepool?ref=v0.9.1"
  project_id                  = module.project.project_id
  cluster_name                = module.gke_application_cluster.name
  location                    = module.gke_application_cluster.location
  name                        = each.key
  node_image_type             = "cos_containerd"
  node_machine_type           = each.value.node_machine_type
  node_service_account        = module.gke_workload_runner.email
  node_service_account_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  autoscaling_config = {
    min_node_count = each.value.min_node_count
    max_node_count = each.value.max_node_count
  }

  node_labels = try(each.value.node_labels, {})

  node_tags = [
    module.gke_application_cluster.name
  ]
}

module "gke_application_cluster-firewall" {
  source      = "github.com/dapperlabs-platform/terraform-google-net-vpc-firewall-yaml?ref=v0.9.0"
  project_id  = module.project.project_id
  network     = module.gke_vpc.name
  config_path = "./vpc-firewall-rules/gke"
}

resource "google_compute_global_address" "ingress" {
  project      = module.project.name
  name         = "ingress-static-ip"
  address_type = "EXTERNAL"
}

resource "kubernetes_priority_class" "gke-application-priority-classes" {
  depends_on = [
    module.gke_application_cluster
  ]
  for_each = {
    default = {
      description    = "Global default priority class"
      value          = 1000
      global_default = true
    }
    low-priority = {
      description = "Low priority"
      value       = 100
    }
    high-priority = {
      description = "High priority"
      value       = 10000
    }
    cluster-critical = {
      description = "Cluster critical. Highest before native k8s system-cluster-critical"
      value       = 1000000000
    }
    node-critical = {
      description = "Node critical. Highest before native k8s system-node-critical"
      value       = 1000000000
    }
  }
  metadata {
    name = "${each.key}.ops.dapperlabs.com"
  }

  global_default = try(each.value.global_default, false)
  description    = each.value.description
  value          = each.value.value
}
