module "repository" {
  source      = "github.com/dapperlabs-platform/terraform-google-artifact-registry?ref=v0.9.3"
  project_id  = var.project_name
  location    = var.default_region
  description = "${var.product_friendly_name} Docker Artifacts"
  format      = "DOCKER"
  id          = var.product_name
}