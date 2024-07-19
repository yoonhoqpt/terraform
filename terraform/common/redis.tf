# Shared Redis subscription is created here.

resource "rediscloud_subscription" "subscription" {
  name = var.product_name

  cloud_provider {
    provider = "GCP"
    region {
      region                       = var.default_region
      multiple_availability_zones  = true
      networking_deployment_cidr   = "192.168.41.0/24"
      preferred_availability_zones = []
    }
  }

  // This whole section is awful - it creates an instance which we can't
  // really configure or use.
  creation_plan {
    average_item_size_in_bytes   = 1024
    memory_limit_in_gb           = 5
    quantity                     = 1
    replication                  = true
    support_oss_cluster_api      = false
    throughput_measurement_by    = "operations-per-second"
    throughput_measurement_value = 5000
    modules                      = []
  }

  // Once this is created - we ignore it - we use the ID to 
  // provision Redis instances on a per environment basis.
  lifecycle {
    ignore_changes = [creation_plan, cloud_provider, payment_method]
  }
}

resource "google_secret_manager_secret" "redis_subscription_id" {
  project   = var.project_name
  secret_id = "redis_subscription_id"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "redis_subscription_id_latest" {
  secret      = google_secret_manager_secret.redis_subscription_id.id
  secret_data = rediscloud_subscription.subscription.id
}
