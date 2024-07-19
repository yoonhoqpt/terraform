# TODO: Go to grafana.com and create an API Key with "viewer" role named <product>-<env>-viewer.
#       Put this API key into Google Secrets Manager in `grafana_viewer`
# TODO: Go to grafana.com and create an API Key with "metrics publichs" role named <product>-<env>-publisher.
#       Put this API key into Google Secrets Manager in `grafana_publisher`
#
# Note: Each service (like Prometheus, Loki, and Tempo) in your
# Grafana Stack, will have a unique username which you can obtain
# from the service 'Details' page in grafana.com. This is what you
# use in combination with an API Key, to authenticate the datasources via basic auth.
# TODO: Once you get those values from the Grafana website - update locals.tf with those values

# The above steps are manual because Grafana Cloud does not yet have a terraform provider
# creating API Keys.

# TODO: Grafana API Keys stored in Google Secrets Manager so we can
# reuse across all environments.

# TODO: Viewer for Datasources.
resource "google_secret_manager_secret" "grafana_viewer" {
  project   = var.project_name
  secret_id = "grafana_viewer"

  replication {
    user_managed {
      replicas {
        location = var.default_region
      }
    }
  }
}

# TODO: Metrics Publisher for Kubernetes Clusters
resource "google_secret_manager_secret" "grafana_publisher" {
  project   = var.project_name
  secret_id = "grafana_publisher"

  replication {
    user_managed {
      replicas {
        location = var.default_region
      }
    }
  }
}

data "google_secret_manager_secret_version" "grafana_viewer" {
  project = var.project_name
  secret  = "grafana_viewer"
}

resource "grafana_data_source" "prometheus_datasource" {
  type                = "prometheus"
  name                = "${var.product_friendly_name} Prometheus"
  url                 = local.prometheus_datasource_url
  basic_auth_enabled  = true
  basic_auth_username = local.prometheus_username
  secure_json_data_encoded = jsonencode({
    basicAuthPassword = data.google_secret_manager_secret_version.grafana_viewer.secret_data
  })
}

resource "grafana_data_source" "loki_datasource" {
  type                = "loki"
  name                = "${var.product_friendly_name} Loki"
  url                 = local.loki_datasource_url
  basic_auth_enabled  = true
  basic_auth_username = local.loki_username
  secure_json_data_encoded = jsonencode({
    basicAuthPassword = data.google_secret_manager_secret_version.grafana_viewer.secret_data
  })
}

module "gcp_metrics_grafana_datasource" {
  source                   = "github.com/dapperlabs-platform/terraform-gcp-metrics-grafana-datasource?ref=v0.9.6"
  project_name             = "dapper-ops"
  service_account_create   = true
  grant_folder_permissions = true
  folder_id                = var.folder_id

  service_account_name    = "${lower(var.product_name)}-metrics-reader"
  grafana_datasource_name = "${var.product_friendly_name} GCP Metrics"
}

# TODO: For deploy annotations from repos that deploy.
#
# locals {
#   github_repos = ["repos", "that", "push-annotations", "go", "here"]
# }

# resource "github_actions_variable" "loki_username" {
#   for_each      = toset(local.github_repos)
#   repository    = each.key
#   variable_name = "LOKI_USERNAME"
#   value         = local.loki_username
# }

# resource "github_actions_variable" "loki_url" {
#   for_each      = toset(local.github_repos)
#   repository    = each.key
#   variable_name = "LOKI_URL"
#   value         = local.loki_datasource_url
# }
