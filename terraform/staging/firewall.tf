# Cloudflare now requires custom rules to be created under a "ruleset". 
# To add additional Firewall rules add a block under the "firewall_rules" variable
# with a comment describing the rule to help identify it.
# More info https://developers.cloudflare.com/ruleset-engine/rulesets-api/.

# Cloudflare Custom Firewall Rules

module "custom_firewall_rules_staging" {
  source = "github.com/dapperlabs-platform/terraform-cloudflare-firewall?ref=v2.3"
  domains = [
    data.cloudflare_zone.internal_zone.name
  ]

  firewall_rules = {
    # Block non employees
    "block_non_employees_v2" = {
      description = "Block ${var.environment} to non employees",
      expression  = <<EOT
    http.host contains "${var.environment}.${data.cloudflare_zone.internal_zone.name}" and not ip.src in $dapperlabs_allowlist
    EOT
      action      = "block",
      enabled     = true,
    },
    # Block Threat Score > 40
    "Block > 40" = {
      description = "Block Threat Score > 40",
      expression  = "(cf.threat_score ge 40)",
      action      = "block",
      enabled     = true,
    },
  }
}

# Cloudflare Managed Rulesets

module "cloudflare_managed_rulesets" {
  source = "github.com/dapperlabs-platform/terraform-cloudflare-managed-rulesets?ref=v1.2"

  domains = [
    data.cloudflare_zone.internal_zone.name
  ]
  # Managed Ruleset - Rulset is fully managed by cloudflare 
  managed_ruleset_enabled = true

  # OWASP Ruleset - https://developers.cloudflare.com/waf/managed-rules/reference/owasp-core-ruleset/#setting-the-paranoia-level
  owasp_enabled           = true
  owasp_action            = "log"
  anomaly_score_threshold = 60 # Set the score threshold which will trigger the Firewall, 60 = low, 40 = medium, 25 = high
  paranoia_level          = 3  # Higher paranoia levels activate more aggressive rules. 1 = PL1, 2 = PL2, 3 = PL3, 4 = PL4

}
