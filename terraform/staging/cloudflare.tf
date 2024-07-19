# Argo tunnel that will proxy cloudflare traffic to the nginx ingress controller
module "cloudflare_tunnel" {
  source                = "git@github.com:dapperlabs/terraform-modules.git//cloudflare-tunnel?ref=cloudflare-tunnel-v2"
  name                  = "${var.product_name}-${var.environment}-${module.gke_application_cluster.cluster.name}"
  cloudflare_account_id = "ea64206f699cea3433e5d8460ca5d791"
}

# Creates <environment> and *.<environment> Edge Certificates and CNAME records pointing to tunnel 
module "cloudflare_internal_records" {
  source                 = "github.com/dapperlabs-platform/terraform-cloudflare-records?ref=v1.0.7"
  cloudflare_zone_domain = data.cloudflare_zone.internal_zone.name
  subdomain              = var.environment
  destination            = module.cloudflare_tunnel.tunnel_cname

  depends_on = [
    module.cloudflare_tunnel
  ]
}
