# Access to shared Artifact Registry Repositories
resource "google_artifact_registry_repository_iam_member" "sre_artifacts_read_only" {
  provider   = google-beta
  project    = "sre-artifacts"
  location   = "us-west1"
  repository = "sre"
  role       = "roles/artifactregistry.reader"
  member     = module.gke_workload_runner.iam_email
}

# resource "google_artifact_registry_repository_iam_member" "flow-artifacts-read-only" {
#   provider   = google-beta
#   project    = "flow-artifacts"
#   location   = "us-west1"
#   repository = "sre"
#   role       = "roles/artifactregistry.reader"
#   member     = module.gke_workload_runner.iam_email
# }

resource "google_artifact_registry_repository_iam_member" "project_artifacts_iam" {
  for_each = toset([
    module.backend_deployer_service_account.iam_email,
    module.frontend_deployer_service_account.iam_email
  ])

  project    = local.artifactregistry_project
  location   = var.default_region
  repository = var.product_name
  role       = "roles/artifactregistry.writer"
  member     = each.key
}

resource "google_project_iam_custom_role" "additional_developer_permissions" {
  role_id     = "dapper.gke.kubernetes.developer"
  title       = "Additional Developer Permissions"
  description = "Collection of perimssions for Developers"
  permissions = ["container.pods.portForward"]
}

resource "google_project_iam_member" "additional_developer_permissions" {
  project = var.project_name
  role    = "projects/${var.project_name}/roles/dapper.gke.kubernetes.developer"
  member  = "group:${var.product_name}-backend-service-developers@access.dapperlabs.com"
}

# This allows the subject to interact with thirdpart objects, e.g. allows deployer service account to interact with cert-manager resources for private CA work
resource "google_project_iam_custom_role" "third-party-resources" {
  role_id     = "thirdPartyResourcesCustomRole"
  title       = "Third Party Resources Custom Role"
  description = "A role that grants specific permissions required by GKE so that the deployer service account can interact with and create third party resources."
  permissions = [
    "container.thirdPartyObjects.create",
    "container.thirdPartyObjects.delete",
    "container.thirdPartyObjects.get",
    "container.thirdPartyObjects.list",
    "container.thirdPartyObjects.update",
    "container.thirdPartyResources.create",
    "container.thirdPartyResources.delete",
    "container.thirdPartyResources.get",
    "container.thirdPartyResources.list",
    "container.thirdPartyResources.update",
  ]
}
