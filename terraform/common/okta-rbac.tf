locals {
  # Uncomment or add if additional is required
  rbacs = {
    backend_service_devs = {
      name : "${var.product_name} Backend Service Developers"
      description : "T2 - BE Engineers - Created in Terraform"
    },
    frontend_service_devs = {
      name : "${var.product_name} Frontend Application Developers"
      description : "T2 - FE Engineers - Created in Terraform"
    },
    incident_responders = {
      name : "${var.product_name} Incident Responders"
      description : "On Call Automation Only - Created in Terraform"
    },
    # creatives = {
    #  name : "${var.product_name} Creatives"
    #   description : "T2 - Created in Terraform"
    # },
    # product_analysts = {
    #   name : "${var.product_name} Product Analysts"
    #   description : "T2 - Created in Terraform"
    # },
    # live_ops = {
    #   name : "${var.product_name} Live Ops Producers"
    #   description : "T2 - Created in Terraform"
    # },
    # product_managers = {
    #   name : "${var.product_name} Product Managers"
    #   description : "T2 - Created in Terraform"
    # },
    # content_producers = {
    #   name : "${var.product_name} Content Producers"
    #   description : "T2 - Created in Terraform"
    # },
    # render_pipeline_engineers = {
    #   name : "${var.product_name} Render Pipeline Engineers"
    #   description : "T2 - Created in Terraform"
    # },
  }
}

# This will create the groups in Okta, an Okta workflow will then create the group in google 
# and add the group to gke-security-groups@dapperlabs.com.
# IT handles group membership.
resource "okta_group" "product_rbacs" {
  for_each = local.rbacs

  name        = each.value.name
  description = each.value.description
}
