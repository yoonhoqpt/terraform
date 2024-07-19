locals {
  flow-keyrings = {
    flow-testnet = {
      keys = {
        signer = {
          signer_verifiers = [
            module.kms_signer_service_account.iam_email,
            "group:${var.product_name}-backend-service-developers@access.dapperlabs.com"
          ]
        }
        pds = {
          signer_verifiers = [
            module.flow_pds_service_account.iam_email,
            "group:${var.product_name}-backend-service-developers@access.dapperlabs.com"
          ]
        }
      }
    }
  }
}

module "kms-flow-keyrings" {
  source     = "github.com/dapperlabs-platform/terraform-google-kms?ref=v0.10.2"
  for_each   = local.flow-keyrings
  project_id = module.project.project_id

  key_purpose = {
    for k, v in each.value.keys :
    k => {
      purpose = "ASYMMETRIC_SIGN"
      version_template = {
        algorithm        = "EC_SIGN_P256_SHA256"
        protection_level = null
      }
    }
  }

  keyring = {
    location = "global"
    name     = "${each.key}-cosigners"
  }

  keys = {
    for k, v in each.value.keys : k => null
  }

  key_iam = {
    for k, v in each.value.keys : k => {
      "roles/cloudkms.signerVerifier" = v.signer_verifiers
    }
  }

  depends_on = [
    module.flow_pds_service_account,
    module.kms_signer_service_account
  ]
}
