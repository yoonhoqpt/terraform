terraform {
  required_version = "~> 1"
  backend "gcs" {}
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.1"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "~> 1.22"
    }
    okta = {
      source  = "okta/okta"
      version = "~> 4.5.0"
    }
    rediscloud = {
      source  = "RedisLabs/rediscloud"
      version = "~> 1.1"
    }
  }
}

provider "cloudflare" {
  # provided by atlantis
}

provider "okta" {
  org_name  = "axiomzenportfolio"
  base_url  = "okta.com"
  client_id = "0oaycbbo2t5AHThSQ357"
  scopes    = ["okta.groups.manage"]
}

module "project" {
  source          = "github.com/dapperlabs-platform/terraform-google-project?ref=v0.9.0"
  name            = var.project_name
  parent          = var.folder_id
  billing_account = var.billing_account_id
  oslogin         = false

  services = [
    "artifactregistry.googleapis.com",
    "secretmanager.googleapis.com",
  ]

  iam_additive = {
    "roles/secretmanager.admin" = [
      "group:sre@dapperlabs.com",
    ]
  }
}
