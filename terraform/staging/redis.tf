# NOTE: THIS IS ONLY FOR PRODUCTION.
#       DO NOT USE THIS FOR STAGING OR DEVELOPMENT.
#       USE MANUALLY DEPLOYED REDIS INSTEAD.
#       LOOK AT `k8s/sre/redis` FOR MORE INFORMATION.

resource "rediscloud_subscription_database" "redis" {
  subscription_id                       = data.google_secret_manager_secret_version.redis_subscription_id.secret_data
  name                                  = var.environment
  protocol                              = "redis"
  memory_limit_in_gb                    = 5
  data_persistence                      = "none"
  throughput_measurement_by             = "operations-per-second"
  throughput_measurement_value          = 5000
  support_oss_cluster_api               = false
  external_endpoint_for_oss_cluster_api = false
  replication                           = true
  enable_tls                            = true
  password                              = random_password.passwords["redis"].result
  modules                               = [{ name = "RedisJSON" }]
}

// NOTE: This tells Redis Cloud to initiate peering from the Redis VPC.
resource "rediscloud_subscription_peering" "peering" {
  subscription_id  = data.google_secret_manager_secret_version.redis_subscription_id.secret_data
  provider_name    = "GCP"
  gcp_project_id   = var.project_name
  gcp_network_name = module.gke_vpc.name
}

// NOTE: This tells GCP to peer with Redis Cloud.
resource "google_compute_network_peering" "default_network_peering" {
  name         = "${var.product_name}-${var.environment}-${var.default_region}"
  network      = module.gke_vpc.self_link
  peer_network = "projects/${rediscloud_subscription_peering.peering.gcp_redis_project_id}/global/networks/${rediscloud_subscription_peering.peering.gcp_redis_network_name}"
}
