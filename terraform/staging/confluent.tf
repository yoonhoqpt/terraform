locals {
  cluster_readers = ["reader", "rw_committer"]
  cluster_writers = ["writer", "rw_committer"]
  default_topic_config = {
    replication_factor = 3
    partitions         = 12
    config = {
      "cleanup.policy" = "delete"
    }
    acl_readers = local.cluster_readers
    acl_writers = local.cluster_writers
  }
}

# Confluent environments are a logical grouping of clusters:
# Org
#  Environment A
#    Cluster A1...
#  Environment B
#    Cluster B1...
#
# The resulting cluster will be named <product>-<var.environment> under a <product> Confluent Cloud Environment

module "confluent_kafka_cluster" {
  # Common settings
  source = "github.com/dapperlabs-platform/terraform-confluent-official-kafka-cluster?ref=v0.14.0"

  name        = var.environment
  environment = var.product_friendly_name
  gcp_region  = var.default_region
  # Settings for production - probably not needed for staging
  # cluster_tier = "DEDICATED"
  # cku          = 2 # multi-zone dedicated clusters must have at least 2 CKUs
  # availability = "MULTI_ZONE"

  service_provider             = "GCP"
  create_grafana_dashboards    = true
  grafana_datasource           = "${var.product_friendly_name} Prometheus"
  service_account_key_versions = ["v1"]

  # exporters settings
  enable_metric_exporters          = true
  kafka_lag_exporter_image_version = "0.7.1"
  ccloud_exporter_image_version    = "latest"

  exporters_node_selector = {
    "ops.dapperlabs.com/preferred-namespace" = "sre"
  }

  kafka_lag_exporter_container_resources = {
    requests = {
      cpu    = "500m"
      memory = "256Mi"
    }
    limits = {
      cpu    = "1"
      memory = "512Mi"
    }
  }

  # Kafka topics list
  topics = {
    "topic-1" = local.default_topic_config,
  }
}
