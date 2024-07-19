# install MacOS Linux sed equivalent
# brew install gsed

# to run, navigate to same directory and run
# bash _module-versions.sh

# ALL of these must be found/replaced; latest version as of 13 June 2022 are below
# cloudflare_bucket                                     = "cloudflare-bucket-v2.1"         # https://github.com/dapperlabs/terraform-modules/releases?q=cloudflare-bucket&expanded=true
# cloudflare_internal_zone_version                      = "cloudflare-internal-zone-v1.13" # https://github.com/dapperlabs/terraform-modules/releases?q=cloudflare-internal
# cloudflare_tunnel_version                             = "cloudflare-tunnel-v1"           # https://github.com/dapperlabs/terraform-modules/releases?q=cloudflare-tunnel
# cloudflare_zone_version                               = "cloudflare-zone-v11"            # https://github.com/dapperlabs/terraform-modules/releases?q=cloudflare-zone
# gen3_grafana_dashboards_version                       = "gen3-grafana-dashboards-v5.4"   # https://github.com/dapperlabs/terraform-modules/releases?q=gen3-grafana-dashboards
# ingress_controller_version                            = "ingress-controller-v1.21"       # https://github.com/dapperlabs/terraform-modules/releases?q=ingress-controller
# terraform_cloudflare_firewall_version                 = "v1.0.1"                         # https://github.com/dapperlabs-platform/terraform-cloudflare-firewall/releases
# terraform_cloudflare_records_version                  = "v1.0.7"                         # https://github.com/dapperlabs-platform/terraform-cloudflare-records/releases
# terraform_confluent_kafka_cluster_version             = "v0.11.1"                        # https://github.com/dapperlabs-platform/terraform-confluent-kafka-cluster/releases
# terraform_confluent_official_kafka_cluster_version    = "v0.14.0"                        # https://github.com/dapperlabs-platform/terraform-confluent-official-kafka-cluster/releases
# terraform_gcp_metrics_grafana_datasource_version      = "v0.9.6"                         # https://github.com/dapperlabs-platform/terraform-gcp-metrics-grafana-datasource/releases
# terraform_google_artifact_registry_version            = "v0.9.3"                         # https://github.com/dapperlabs-platform/terraform-google-artifact-registry/releases
# terraform_google_database_version                     = "v1.1.4"                         # https://github.com/dapperlabs-platform/terraform-google-database/releases
# terraform_google_gcs_version                          = "v0.9.5"                         # https://github.com/dapperlabs-platform/terraform-google-gcs/releases
# terraform_google_gke_cluster_version                  = "v0.9.11"                        # https://github.com/dapperlabs-platform/terraform-google-gke-cluster/releases
# terraform_google_gke_nodepool_version                 = "v0.9.1"                         # https://github.com/dapperlabs-platform/terraform-google-gke-nodepool/releases
# terraform_google_iam_service_account_version          = "v1.1.6"                         # https://github.com/dapperlabs-platform/terraform-google-iam-service-account/releases
# terraform_google_kms_version                          = "v0.10.2"                        # https://github.com/dapperlabs-platform/terraform-google-kms/releases
# terraform_google_net_address_version                  = "v0.9.0"                         # https://github.com/dapperlabs-platform/terraform-google-net-address/releases
# terraform_google_net_cloudnat_version                 = "v0.9.1"                         # https://github.com/dapperlabs-platform/terraform-google-net-cloudnat/releases
# terraform_google_net_vpc_version                      = "v0.9.0"                         # https://github.com/dapperlabs-platform/terraform-google-net-vpc/releases
# terraform_google_net_vpc_firewall_yaml_version        = "v0.9.0"                         # https://github.com/dapperlabs-platform/terraform-google-net-vpc-firewall-yaml/releases
# terraform_google_project_version                      = "v0.9.0"                         # https://github.com/dapperlabs-platform/terraform-google-project/releases
# terraform_gcp_spanner_version                         = "v0.3.4"                         # https://github.com/dapperlabs-platform/terraform-gcp-spanner/releases
# terraform_grafana_synthetic_monitoring_checks_version = "v0.9.5"                         # https://github.com/dapperlabs-platform/terraform-grafana-synthetic-monitoring-checks/releases
# terraform_redis_cluster_gcp_version                   = "v0.9.18"                        # https://github.com/dapperlabs-platform/terraform-redis-cluster-gcp/releases
# terraform_google_cas                                  = "v0.9.1"                         # https://github.com/dapperlabs-platform/terraform-google-cas/releases

# GSED TEMPLATE
# gsed -i -E 's/(").*/\1vX.X.X"/' *.tf

workingdir="${1:-"./"}"
[[ "${workingdir}" != */ ]] && workingdir="${workingdir}/"
echo "Processing '${workingdir}'..."

find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("git@github\.com:dapperlabs\/terraform-modules\.git\/\/cloudflare-bucket\?ref=).*/\1cloudflare-bucket-v2.1"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("git@github\.com:dapperlabs\/terraform-modules\.git\/\/cloudflare-internal-zone\?ref=).*/\1cloudflare-internal-zone-v1.13"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("git@github\.com:dapperlabs\/terraform-modules\.git\/\/cloudflare-tunnel\?ref=).*/\1cloudflare-tunnel-v1"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("git@github\.com:dapperlabs\/terraform-modules\.git\/\/cloudflare-zone\?ref=).*/\1cloudflare-zone-v11"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("git@github\.com:dapperlabs\/terraform-modules\.git\/\/gen3-grafana-dashboards\?ref=).*/\1gen3-grafana-dashboards-v5.5"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("git@github\.com:dapperlabs\/terraform-modules\.git\/\/ingress-controller\?ref=).*/\1ingress-controller-v1.21"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-cloudflare-firewall\?ref=).*/\1v1.0.1"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-cloudflare-records\?ref=).*/\1v1.0.7"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-confluent-kafka-cluster\?ref=).*/\1v0.11.1"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-confluent-official-kafka-cluster\?ref=).*/\1v0.14.0"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-gcp-metrics-grafana-datasource\?ref=).*/\1v0.9.6"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-google-artifact-registry\?ref=).*/\1v0.9.3"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-google-database\?ref=).*/\1v1.1.4"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-google-gcs\?ref=).*/\1v0.9.5"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-google-gke-cluster\?ref=).*/\1v0.9.11"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-google-gke-nodepool\?ref=).*/\1v0.9.1"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-google-iam-service-account\?ref=).*/\1v1.1.6"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-google-kms\?ref=).*/\1v0.10.2"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-google-net-address\?ref=).*/\1v0.9.0"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-google-net-cloudnat\?ref=).*/\1v0.9.1"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-google-net-vpc\?ref=).*/\1v0.9.0"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-google-net-vpc-firewall-yaml\?ref=).*/\1v0.9.0"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-google-project\?ref=).*/\1v0.9.0"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-gcp-spanner\?ref=).*/\1v0.3.4"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-grafana-synthetic-monitoring-checks\?ref=).*/\1v0.9.5"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-redis-cluster-gcp\?ref=).*/\1v0.9.18"/'
find ${workingdir} -name '*.tf' | xargs gsed -i -E 's/("github\.com\/dapperlabs-platform\/terraform-google-cas\?ref=).*/\1v0.9.1"/'
