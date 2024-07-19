/*
* ⚠️ iam_project_roles keys are project names. We can't use the project module name output here
* because terraform won't know what it is until apply, so we fall back to the local variable used
* to name the project.
*/

module "gke_workload_runner" {
  depends_on = [module.project]
  source     = "github.com/dapperlabs-platform/terraform-google-iam-service-account?ref=v1.1.10"
  project_id = module.project.project_id
  name       = "gke-workload-runner"
  iam_project_roles = {
    "${var.project_name}" = [
      "roles/artifactregistry.reader",
      "roles/logging.logWriter"
    ]
  }
}

module "frontend_deployer_service_account" {
  depends_on = [module.project]
  source     = "github.com/dapperlabs-platform/terraform-google-iam-service-account?ref=v1.1.10"
  project_id = module.project.project_id
  name       = "frontend-deployer"
  iam_project_roles = {
    "${var.project_name}" = [
      "roles/container.clusterViewer",
      "roles/cloudbuild.builds.editor",
    ]
    "sre-artifacts" = [
      "roles/artifactregistry.reader",
    ]
  }
  github_workload_identity_federation = [{
    environment = var.environment
    # TODO update me
    repository = "dapperlabs/<frontend-repo>"
  }]
}

module "backend_deployer_service_account" {
  depends_on = [module.project]
  source     = "github.com/dapperlabs-platform/terraform-google-iam-service-account?ref=v1.1.10"
  project_id = module.project.project_id
  name       = "backend-deployer"
  iam_project_roles = {
    "${var.project_name}" = [
      "roles/container.clusterViewer",
      "roles/cloudbuild.builds.editor",
      google_project_iam_custom_role.third-party-resources.name, # needed if using Private-CA module
    ]
    "sre-artifacts" = [
      "roles/artifactregistry.reader",
    ]
  }
  github_workload_identity_federation = [{
    environment = var.environment
    # TODO update me
    repository = "dapperlabs/<backend-repo>"
  }]
}

module "kms_signer_service_account" {
  source     = "github.com/dapperlabs-platform/terraform-google-iam-service-account?ref=v1.1.10"
  project_id = module.project.project_id
  name       = "kms-signer"
}

module "flow_pds_service_account" {
  source     = "github.com/dapperlabs-platform/terraform-google-iam-service-account?ref=v1.1.10"
  project_id = module.project.project_id
  name       = "flow-pds"
}
