module "cloud_spanner_instance" {
  source = "github.com/dapperlabs-platform/terraform-gcp-spanner?ref=v0.5.0"

  instance_iam = [
    { role = "roles/spanner.admin", members = ["group:sre@dapperlabs.com"] },
    { role = "roles/spanner.viewer",
      members = [
        "group:${var.product_name}-frontend-application-developers@access.dapperlabs.com",
        "group:${var.product_name}-backend-service-developers@access.dapperlabs.com"
      ]
    }
  ]

  # Name and enviroment needs to be under 28 characters total or will error
  name   = "${var.product_name}-${var.environment}"
  config = "regional-${var.default_region}" # # see https://cloud.google.com/spanner/docs/instance-configurations; regional configs are always prefixed with `regional-<name>`
  databases = [{
    name      = "${var.product_name}"
    charset   = "UTF8"
    collation = "en_US.UTF8"
    }
  ]

  database_iam = {
    "admins_${var.product_name}_${var.environment}" = {
      role          = "roles/spanner.databaseAdmin",
      database_name = "${var.product_name}",
      members = [
        "group:${var.product_name}-frontend-application-developers@access.dapperlabs.com",
        "group:${var.product_name}-backend-service-developers@access.dapperlabs.com"
      ]
    }
  }

  depends_on = [
    module.frontend_deployer_service_account,
    module.backend_deployer_service_account
  ]
}
