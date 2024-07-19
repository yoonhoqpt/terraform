#argoCD Okta App
module "argocd-okta-app" {
  source = "github.com/dapperlabs-platform/terraform-okta-application?ref=v2.2"

  name     = "" #TODO name of the app
  sso_url  = "" #TODO sso url
  hide_web = true

  # Requires group name as displayed in Okta, check rbac tool in retool for reference or ask IT
  okta_groups = ["SRE", ]
}
