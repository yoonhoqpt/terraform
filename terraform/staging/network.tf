locals {
  region_configs = {
    "${var.default_region}" = {
      subnets = {
        gke = {
          ip_cidr_range               = "10.0.0.0/20"    # 4096 addresses
          pods_secondary_ip_range     = "172.16.0.0/15"  # 131070 addresses
          services_secondary_ip_range = "192.168.0.0/19" # 8190 addresses
        }
      }
      nat_ip_count = 3
    }
  }
}

resource "google_secret_manager_secret" "egress_ips" {
  secret_id = "egress-ips"
  replication {
    automatic = true
  }
  labels = {
    "managed-by" = "terraform"
  }
}

module "gke_vpc_nat_addresses" {
  source     = "github.com/dapperlabs-platform/terraform-google-net-address?ref=v0.9.0"
  for_each   = local.region_configs
  project_id = module.project.project_id
  external_addresses = {
    for i in range(each.value.nat_ip_count) :
    "nat-${i + 1}" => each.key
  }
}

resource "google_secret_manager_secret_version" "egress_ips_latest" {
  secret = google_secret_manager_secret.egress_ips.id
  # Store comma-separated list of IP addresses 1.1.1.1,2.2.2.2,3.3.3.3...
  secret_data = join(",", flatten([for v in module.gke_vpc_nat_addresses : [for o in v.external_addresses : o.*.address]]))
}

module "gke_vpc" {
  source     = "github.com/dapperlabs-platform/terraform-google-net-vpc?ref=v0.9.0"
  project_id = module.project.project_id
  name       = var.cluster_network_name
  subnets = flatten(
    [for region, value in local.region_configs :
      [for name, subnet in value.subnets : {
        ip_cidr_range = subnet.ip_cidr_range
        name          = name
        region        = region
        secondary_ip_range = {
          pods     = subnet.pods_secondary_ip_range
          services = subnet.services_secondary_ip_range
        }
      }]
  ])
}

module "cloud-nat" {
  source                  = "github.com/dapperlabs-platform/terraform-google-net-cloudnat?ref=v0.9.1"
  for_each                = local.region_configs
  project_id              = module.project.project_id
  region                  = each.key
  name                    = "${each.key}-nat"
  router_network          = module.gke_vpc.name
  config_min_ports_per_vm = 1024
  addresses               = [for k, value in module.gke_vpc_nat_addresses[each.key].external_addresses : value.self_link]
}
