module "ingress_controller" {
  source                  = "git@github.com:dapperlabs/terraform-modules.git//ingress-controller?ref=ingress-controller-v1.22"
  cloudflared_credentials = module.cloudflare_tunnel.tunnel_creds
  namespace               = "sre"

  replicas = {
    # 6 for prod at least
    min = 3
    max = 24
  }
}
