module "frontend" {
  depends_on = [
    module.gke_workload_runner
  ]
  source     = "github.com/dapperlabs-platform/terraform-google-artifact-registry?ref=v0.9.3"
  project_id = module.project.project_id
  location   = var.default_region
  format     = "DOCKER"
  id         = "frontend"
  iam = {
    "roles/artifactregistry.admin" = [
      module.frontend_deployer_service_account.iam_email
    ]
    "roles/artifactregistry.reader" = [
      module.gke_workload_runner.iam_email
    ]
    "roles/artifactregistry.writer" = []
  }

  iam_additive = {}
}

module "backend" {
  source     = "github.com/dapperlabs-platform/terraform-google-artifact-registry?ref=v0.9.3"
  project_id = module.project.project_id
  location   = var.default_region
  format     = "DOCKER"
  id         = "backend"
  iam = {
    "roles/artifactregistry.admin" = [
      module.backend_deployer_service_account.iam_email
    ]
    "roles/artifactregistry.writer" = []
  }

  iam_additive = {}
}
