# ⚠️ The Grafana API complains if you try to create multiple checks concurrently.
# See https://github.com/dapperlabs/terraform/pull/2007#issuecomment-997400038
# There's an open issue to allow looped resources to specify paralallesim
# https://github.com/hashicorp/terraform-plugin-sdk/issues/67
# For now, when the creation of this module fails, apply with -parallelism=1
# `atlantis apply -- -target=module.synthetic_monitoring_checks -parallelism=1
module "synthetic_monitoring_checks" {
  source            = "github.com/dapperlabs-platform/terraform-grafana-synthetic-monitoring-checks?ref=v0.9.5"
  alert_sensitivity = "medium"
  labels = {
    "product"     = var.product_name
    "environment" = var.environment
  }
  dns_targets = [
    "${var.environment}.${var.product_name}.dapperlabs.com"
  ]
  dns_record_type = "CNAME"
  job_name        = "${var.product_friendly_name} Synthetic Check"

  http_targets = [
    "${var.environment}.${var.product_name}.dapperlabs.com"
  ]
  # We expect cloudflare to block non-production; remove if production
  http_valid_status_codes = [403]

  disable_probes = []
}

module "grafana_dashboards" {
  source               = "git@github.com:dapperlabs/terraform-modules.git//gen3-grafana-dashboards?ref=gen3-grafana-dashboards-v5.7"
  folder_name          = "${var.product_friendly_name} SRE (${var.environment})"
  gcp_datasource       = local.grafana_data_source_gcp_name
  gcp_datasource_uid   = local.grafana_data_source_gcp_id
  gcs_bucket_name      = "does-not-exist"
  loki_datasource      = local.grafana_data_source_loki_name
  loki_datasource_uid  = local.grafana_data_source_loki_id
  prom_datasource      = local.grafana_data_source_prometheus_name
  prom_datasource_uid  = local.grafana_data_source_prometheus_id
  notification_channel = local.grafana_notification_channel
  product_name         = var.product_friendly_name
  project_name         = var.project_name
  environment          = var.environment
  service_name         = "${var.product_name}-infrastructure"
  dashboards = [
    "cloudflared",
    "cloudsql",
    "ingress",
    "kubernetes",
    "observability",
    "kyverno",
    "kyverno-policies"
  ]
}

module "spanner_dashboards" {
  source               = "github.com/dapperlabs-platform/terraform-spanner-dashboards?ref=v0.13.0"
  folder_id            = module.grafana_dashboards.folder_id
  gcp_datasource       = local.grafana_data_source_gcp_name
  gcp_datasource_uid   = local.grafana_data_source_gcp_id
  prom_datasource      = local.grafana_data_source_prometheus_name
  prom_datasource_uid  = local.grafana_data_source_prometheus_id
  notification_channel = local.grafana_notification_channel
  product_name         = var.product_friendly_name
  project_name         = var.project_name
  environment          = var.environment
  service_name         = "${var.product_name}-infrastructure"
}

# Must be deployed after k8s manifests are deployed - depends on the wrapped secret deployed in k8s/sre/sre-resources/base/wrapped-secrets.yaml
// module "grafana_agent_tracing_deployment" {
//   source                   = "github.com/dapperlabs-platform/grafana-agent-traces?ref=${local.grafana_agent_traces_version}"
//   namespace                = "sre"
//   project                  = var.product_name
//   environment              = var.environment
//   deployment_replica_count = 3
//   # Send traces to the shared Tempo instance
//   tempo_username = "241724"
//   tempo_endpoint = "tempo-us-central1.grafana.net:443"
//   tempo_api_key_secret = {
//     # k8s/sre/sre-resources/base/wrapped-secrets.yaml
//     name = "grafana-metrics-publisher"
//     key  = "password"
//   }
// }

# NOTE: FOR NON PRODUCTION ONLY
# module "redis_in_cluster_grafana_dashboard" {
#   source              = "github.com/dapperlabs-platform/terraform-redis-in-cluster-dashboard?ref=v0.9.0"
#   folder_uid          = module.grafana_dashboards.folder_id
#   prom_datasource_uid = local.grafana_data_source_prometheus_id
#   product_name        = var.product_friendly_name
#   project_name        = var.project_name
#   environment         = var.environment
#   service_name        = "${var.product_name}-infrastructure"
# }

// NOTE: FOR PRODUCTION ONLY
// Must be deployed after the Prometheus changes are deployed.
// It needs the cluster and bdb variables from the metrics.
# module "redis_dashboard" {
#   source               = "github.com/dapperlabs-platform/terraform-grafana-redis-dashboard?ref=v0.10.0"
#   bdb                  = "" # TODO
#   cluster              = "" # TODO
#   environment          = var.environment
#   folder_id            = module.grafana_dashboards.folder_id
#   product_name         = title(var.product_name)
#   prom_datasource      = local.grafana_data_source_prometheus_id
#   notification_channel = local.grafana_notification_channel
#   service_name         = "${var.product_name}-infrastructure"
#   # Alerting thresholds
#   cpu_per_shard_threshold         = "75"
#   latency_threshold               = "2000"
#   listener_latency_threshold      = "1000"
#   operations_per_second_threshold = "20000"
#   storage_used_threshold          = "4294967296"
# }
