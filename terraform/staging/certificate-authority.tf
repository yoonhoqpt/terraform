locals {
  organization        = "Dapper Labs"
  organizational_unit = "SRE"
  lifetime            = "946100000s" # ~30 years
  algorithm           = "EC_P256_SHA256"
}

# Creates two CA pools, a root pool and a subordinate pool, each with a CA. Also creates a GCP service account with certificateRequester
# permissions on the subordinate pool. This service account should be added to the cert-manager namespace as a part of workload identity
# in the terraform-google-gke-cluster module (usually found in the cluster.tf file).

#TODO: uncomment if you need to create CAs for temporal
#module "temporal-private-ca" {
#  source = "github.com/dapperlabs-platform/terraform-google-cas?ref=v0.9.3"
#
#  region      = var.default_region
#  project_id  = var.project_name
#  environment = var.environment
#  root_config = {
#    organization        = local.organization
#    organizational_unit = local.organizational_unit
#    common_name         = "${var.project_name}-ca-temporal-[YEAR]" # TODO: REPLACE
#    lifetime            = local.lifetime
#    algorithm           = local.algorithm
#  }
#
#  subordinate_config = {
#    organization        = local.organization
#    organizational_unit = local.organizational_unit
#    common_name         = "${var.project_name}-ca-sub-temporal-[YEAR]" # TODO: REPLACE
#    lifetime            = local.lifetime
#    algorithm           = local.algorithm
#  }
#
#  # These settings should be changed to true, false, false after confirming CAs are configured correctly
#  deletion_protection                    = false # If set to true, Terraform will not be able to delete the CAs
#  skip_grace_period                      = true  # If set to false, CAs will wait 30 days to be deleted
#  ignore_active_certificates_on_deletion = true  # If set to false, Terraform will not delete if there are active Certificates tied to either CA
#}

