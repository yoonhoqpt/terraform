locals {
  # terraform v0.15+
  # Desensitize this secret because it's a comma-separated list of IP addresses
  github_actions_runner_egress_ips = {
    for idx, ip in nonsensitive(split(",", try(data.google_secret_manager_secret_version.gha_ips_latest.secret_data, ""))) :
    "Github Actions Runner NAT IP ${idx}" => "${ip}/32"
  }
  perimeter_81_ips = {
    for idx, ip in nonsensitive(split(",", try(data.google_secret_manager_secret_version.vpn_ips_latest.secret_data, ""))) :
    "Perimeter81 ${idx}" => "${ip}/32"
  }
  atlantis_ips = {
    for idx, ip in nonsensitive(split(",", try(data.google_secret_manager_secret_version.atlantis_ips_latest.secret_data, ""))) :
    "Atlantis ${idx}" => "${ip}/32"
  }
}

# Dapperlabs-CI GHA Egress IPs
data "google_secret_manager_secret_version" "gha_ips_latest" {
  secret  = "github-actions-addresses"
  project = "dapperlabs-ci"
}

# Dapperlabs VPN IPs
data "google_secret_manager_secret_version" "vpn_ips_latest" {
  secret  = "vpn-ips"
  project = "dapper-ops"
}

# Atlantis IPs
data "google_secret_manager_secret_version" "atlantis_ips_latest" {
  secret  = "dl-sre-production-gke-application-cluster-vpc-egress-ips"
  project = "dl-sre-production"
}

data "cloudflare_zone" "internal_zone" {
  name = "${var.product_name}.dapperlabs.com"
}

data "google_secret_manager_secret_version" "redis_subscription_id" {
  project = "dl-${var.product_name}-common"
  secret  = "redis_subscription_id"
}