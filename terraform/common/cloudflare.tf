module "internal_zone" {
  source             = "git@github.com:dapperlabs/terraform-modules.git//cloudflare-internal-zone?ref=cloudflare-internal-zone-v1.15"
  new_zone_subdomain = var.product_name
  cloudflare_plan    = "enterprise"
  identity_providers = [
    # Okta
    # https://dash.teams.cloudflare.com/ea64206f699cea3433e5d8460ca5d791/settings/authentication/idp/edit/a4344e89-a126-4704-a6f0-e6617db9e8bf
    "a4344e89-a126-4704-a6f0-e6617db9e8bf"
  ]
}

# This module creates the public-facing zone for our app (nbatopshot.com, nflallday.com etc...)
# module "<public>_zone" {
#   source          = "git@github.com:dapperlabs/terraform-modules.git//cloudflare-zone?ref=cloudflare-zone-v11"
#   domain          = "<domain>.com"
#   cloudflare_plan = "enterprise"
#   image_resizing  = "open"
#   # Required. Leverage DMARC Digests
#   dmarc_value = ""
#   mx_records  = []
#   # SPF and DKIM records
#   mailsec_records = []
# }
