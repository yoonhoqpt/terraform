locals {
  # TODO update me
  artifactregistry_project            = "project name"
  grafana_data_source_loki_id         = "<get from common output or grafana data sources>"
  grafana_data_source_loki_name       = "<get from common output or grafana data sources>"
  grafana_data_source_prometheus_id   = "<get from common output or grafana data sources>"
  grafana_data_source_prometheus_name = "<get from common output or grafana data sources>"
  grafana_data_source_tempo_id        = "<get from common output or grafana data sources>"
  grafana_data_source_tempo_name      = "<get from common output or grafana data sources>"
  grafana_data_source_gcp_id          = "<get from common output or grafana data sources>"
  grafana_data_source_gcp_name        = "<get from common output or grafana data sources>"
  grafana_notification_channel        = "WNqG4oT7z" # Goes to #dev-null-alerts in Slack
  # For Human SQL access - these are the GCP IAM permissions that are required.
  human_sql_access_iam_permissions = [
    "group:${var.product_name}-backend-service-developers@access.dapperlabs.com",
    "group:sre@dapperlabs.com"
  ]
  # Each of these Human users will have a GCP Postgres CLOUD_IAM_USER user created.
  # See https://cloud.google.com/sql/docs/postgres/iam-logins for more info
  human_sql_iam_users = []
}
