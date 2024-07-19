locals {
  frontend-secrets = {
    # secret-name = {
    #   data = {}
    # }
  }
  backend-secrets = {
    "${var.product_name}-api" = {
      data = {
        consumer_db_password  = random_password.passwords["consumer-db"].result
        waterhose_db_password = random_password.passwords["waterhose-db"].result
        redisConnection       = rediscloud_subscription_database.redis.private_endpoint
        redisPassword         = random_password.passwords["redis"].result
      }
    }
  }
  sre-secrets = {
    github-actions-credentials = {
      data = {
        github_token = var.gh_personal_access_token
      }
    }
  }
  policy-reporter-secrets = {
    mailgun-api-key = {
      data = {
        api-key = data.google_secret_manager_secret_version.mailgun_api_key.secret_data
      }
    }
  }
}

resource "random_password" "passwords" {
  for_each = toset([
    "consumer-db",
    "waterhose-db",
    "redis"
  ])
  length  = 32
  special = false
}

# Frontend secrets
resource "kubernetes_secret" "frontend-secrets" {
  depends_on = [
    module.gke_application_cluster
  ]
  for_each = local.frontend-secrets

  type = "kubernetes.io/opaque"
  metadata {
    name      = each.key
    namespace = "frontend"
  }
  data = each.value.data
}

# Backend secrets
resource "kubernetes_secret" "backend-secrets" {
  depends_on = [
    module.gke_application_cluster,
  ]
  for_each = local.backend-secrets

  type = "kubernetes.io/opaque"
  metadata {
    name      = each.key
    namespace = "backend"
  }
  data = each.value.data
}

# SRE secrets
resource "kubernetes_secret" "sre-secrets" {
  depends_on = [
    module.gke_application_cluster,
  ]
  for_each = local.sre-secrets

  type = "kubernetes.io/opaque"
  metadata {
    name      = each.key
    namespace = "sre"
  }
  data = each.value.data
}

# Policy Reporter secrets
resource "kubernetes_secret" "policy-reporter-secrets" {
  depends_on = [
    module.gke_application_cluster,
  ]
  for_each = local.policy-reporter-secrets

  type = "kubernetes.io/opaque"
  metadata {
    name      = each.key
    namespace = "policy-reporter"
  }
  data = each.value.data
}

data "google_secret_manager_secret_version" "mailgun_api_key" {
  project = "dl-sre-production"
  secret  = "mailgun-api-key"
}
