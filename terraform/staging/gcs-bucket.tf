# Cloudbuild needs this to upload and download source.
module "private_asset_bucket" {
  source     = "github.com/dapperlabs-platform/terraform-google-gcs?ref=v0.9.7"
  project_id = module.project.project_id
  name       = "${var.project_name}_cloudbuild"
  location   = var.default_region
  iam = {
    "roles/storage.admin" = [
      "serviceAccount:${module.backend_deployer_service_account.email}",
      "serviceAccount:${module.frontend_deployer_service_account.email}",
    ]
  }
  public_access_prevention = "enforced"
  storage_class            = "STANDARD"
}
