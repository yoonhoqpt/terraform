locals {
  region         = var.default_region
  zone           = "${var.default_region}-a"
  secondary_zone = "${var.default_region}-c"
  tier           = "db-custom-4-15360"
  authorized_networks = concat(
    [
      for k, v in module.gke_vpc_nat_addresses[var.default_region].external_addresses :
      { name = k, value = v.address }
    ],
    [
      { name = "Hosted Github Runners NAT", value = "35.185.212.84/32" },
    ]
  )
  database_flags = [{
    name  = "autovacuum",
    value = "off"
    }, {
    name  = "cloudsql.iam_authentication",
    value = "on"
  }]
  ip_configuration = {
    ipv4_enabled        = true
    require_ssl         = false
    private_network     = null
    authorized_networks = local.authorized_networks
  }
}

module "cloud-sql-instance" {
  source               = "github.com/dapperlabs-platform/terraform-google-database?ref=v1.1.4"
  name                 = "${var.product_name}-${var.environment}"
  random_instance_name = true
  project_id           = module.project.project_id
  database_version     = "POSTGRES_13"
  region               = local.region

  // Master configurations
  tier                            = local.tier
  zone                            = local.zone
  secondary_zone                  = local.secondary_zone
  availability_type               = "REGIONAL"
  maintenance_window_day          = 7
  maintenance_window_hour         = 12
  maintenance_window_update_track = "stable"
  deletion_protection             = false
  # create databases from `additional_databases` list
  enable_default_db   = false
  enable_default_user = false
  database_flags      = local.database_flags
  ip_configuration    = local.ip_configuration

  insights_config = {
    query_insights_enabled  = "true"
    query_string_length     = "1024"
    record_application_tags = "false"
    record_client_address   = "false"
  }

  user_labels = {
    environment = var.environment
  }

  backup_configuration = {
    enabled                        = true
    start_time                     = "20:55"
    location                       = null
    point_in_time_recovery_enabled = false
    transaction_log_retention_days = null
    retained_backups               = 365
    retention_unit                 = "COUNT"
  }

  // Read replica configurations
  read_replicas = [{
    name             = "1"
    zone             = "${var.default_region}-b"
    tier             = local.tier
    ip_configuration = local.ip_configuration
    database_flags   = []
    disk_autoresize  = true
    disk_size        = null
    disk_type        = null
    user_labels      = null
    }
  ]

  additional_databases = [{
    name      = "consumer-db"
    charset   = "UTF8"
    collation = "en_US.UTF8"
    }, {
    name      = "waterhose-db"
    charset   = "UTF8"
    collation = "en_US.UTF8"
    },
  ]

  additional_users = [{
    name     = "consumer-db"
    password = random_password.passwords["consumer-db"].result
    }, {
    name     = "waterhose-db"
    password = random_password.passwords["waterhose-db"].result
  }]
}

# // SQL IAM Access - add users to locals.tf
# resource "google_sql_user" "human_sql_iam_users" {
#   for_each = toset(local.human_sql_iam_users)
#   name     = each.key
#   instance = module.cloud-sql-instance.instance_name
#   type     = "CLOUD_IAM_USER"
# }

# module "postgres_database-read-only" {
#   source           = "github.com/dapperlabs-platform/terraform-postgres-grants?ref=v0.9.0"
#   database         = "database-name"
#   role             = "role-name-goes-here"
#   tables           = ["tables", "go", "here"]
#   table_privileges = ["SELECT"]
#   users            = local.human_sql_iam_users
# }
