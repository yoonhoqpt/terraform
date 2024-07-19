terraform {
  required_version = "~> 1"
  backend "gcs" {}
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.1"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.18.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.55.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.55.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.19"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 1.22"
    }
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 1.0.0"
    }
    rediscloud = {
      source  = "RedisLabs/rediscloud"
      version = "~> 1.1"
    }
    okta = {
      source  = "okta/okta"
      version = "~> 4.5"
    }
    # postgresql = {
    #   source  = "cyrilgdn/postgresql"
    #   version = "1.19.0"
    # }
  }
}

provider "google" {
  project = var.project_name
  region  = var.default_region
}

data "google_client_config" "provider" {}

provider "github" {
  # owner = GITHUB_OWNER environment variable
  # token = GITHUB_TOKEN environment variable
}

provider "grafana" {
  # url = GRAFANA_URL environment variable
  # auth = GRAFANA_AUTH environment variable
}

provider "kubernetes" {
  host  = "https://${module.gke_application_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    module.gke_application_cluster.ca_certificate,
  )
}

provider "okta" {
  org_name  = "axiomzenportfolio"
  base_url  = "okta.com"
  client_id = "0oaycbbo2t5AHThSQ357"
  scopes    = ["okta.groups.manage", "okta.apps.manage", "okta.policies.manage"]
}

# # To create GRANT statements for CloudSQL IAM users and databases.
# provider "postgresql" {
#   scheme   = "gcppostgres"
#   host     = module.cloud-sql-instance.instance_connection_name
#   username = "postgres"
#   password = data.google_secret_manager_secret_version.postgres_database_user_password.secret_data
# }

# // NOTE: Database password must be set as a Google Secret.
# data "google_secret_manager_secret_version" "postgres_database_user_password" {
#   project = var.project_name
#   secret  = "postgres_database_user_password"
# }

provider "cloudflare" {
  # provided by atlantis
}

provider "confluent" {
  # cloud_api_key    = CONFLUENT_CLOUD_API_KEY environment variable
  # cloud_api_secret = CONFLUENT_CLOUD_API_SECRET environment variable
}

module "project" {
  source          = "github.com/dapperlabs-platform/terraform-google-project?ref=v0.9.0"
  name            = var.project_name
  parent          = var.folder_id
  billing_account = var.billing_account_id
  oslogin         = false

  services = [
    "admin.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudscheduler.googleapis.com",
    "container.googleapis.com",
    "gcp.redisenterprise.com",
    "iap.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
    "stackdriver.googleapis.com",
    "storage-api.googleapis.com",
  ]

  iam_additive = {
    # ----REQUIRED----:
    # The container.admin role must exist for the SRE group + 2 service accounts
    # in order to do CI/CD. Do not remove these. You may add below.
    "roles/container.admin" = [
      # (DONT REMOVE) )SRE
      "group:sre@dapperlabs.com",
      # (DONT REMOVE) Let atlantis manage GKE
      "serviceAccount:terraform@dapper-ops.iam.gserviceaccount.com",
      # (DONT REMOVE) Let SRE GHA Runners create charts
      "serviceAccount:sre-github-actions-runner@dapperlabs-ci.iam.gserviceaccount.com"
      # --- ADD ADDITIONAL GRANTS TO container.admin ROLE BELOW ---
      # TODO update me after IT has created backend and frontend RBAC groups and added both to gke-security-groups@dapperlabs.com
      # so they can be granted k8s access https://cloud.google.com/kubernetes-engine/docs/how-to/google-groups-rbac
      # NOTE: This is to be removed for production.
      # "group:${var.product_name}-backend-service-developers@access.dapperlabs.com",
      # "group:${var.product_name}-frontend-application-developers@access.dapperlabs.com",
    ]
    # ----OPTIONAL----
    # IAM Roles can be added as requested by teams. 
    # The roles along with permissions provided can be found: https://cloud.google.com/iam/docs/understanding-roles 
    # The following are some examples that have been requested by teams.
    # -----------------
    # To give read-only permissions across WHOLE GCP account (very permissive)
    # Source:   
    # "roles/viewer" = [
    #   # "group:${var.product_name}-backend-service-developers@access.dapperlabs.com",
    #   # "group:${var.product_name}-frontend-application-developers@access.dapperlabs.com",
    # ]
    #
    # To give the ability to pull container images. (Usually given to FE and BE teams)
    # "roles/artifactregistry.reader" = [
    #   # "group:${var.product_name}-backend-service-developers@access.dapperlabs.com",
    #   # "group:${var.product_name}-frontend-application-developers@access.dapperlabs.com",
    # ]
    #
    # To give the ability to talk to the DB's. (Usually given to BE on nonprod, incident responders on prod)
    # "roles/cloudsql.client" = [
    #   # backend groups on nonprod
    #   # incident responders on prod
    # ]
    #
    # To allow deployment of Redis Enterprise subscriptions & nodes
    # "roles/serviceusage.serviceUsageAdmin" = [
    #   "group:sre@dapperlabs.com"
    # ]
    # "roles/redisenterprisecloud.admin" = [
    #   "group:sre@dapperlabs.com"
    # ]
    # "roles/cloudsql.client"       = local.human_sql_access_iam_permissions
    # "roles/cloudsql.instanceUser" = local.human_sql_access_iam_permissions
  }
}
