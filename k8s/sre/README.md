# Helm Chart Management

Deploying charts in this folder requires elevated K8S cluster privileges because they may create namespaces, secrets, service accounts etc...

We're currently impersonating the `sre-github-actions-runner@dapperlabs-ci.iam.gserviceaccount.com` service account to manage these charts. The `sre` service account doesn't have any keys and is authenticated via Github Workload Identity Federation configured in [dapperlabs/terraform's dapperlabs-ci/workload-identity-federation.tf](https://github.com/dapperlabs/terraform/blob/master/Dapperlabs-ci/workload-identity-federation.tf).

This service account can only be impersonated from the repos configured in that terraform file, and from workloads that run `sre` environments configured in each repo. SREs are the only administrators on those repos, so changes to their environments must go through SRE.

In order to avoid maintaining an environment on each Gen3 infra repo and allowing workflows from those repos to impersonate the SRE service account, we moved the execution of those charts to the [dapperlabs/sre-infrastructure](https://github.com/dapperlabs/sre-infrastructure/actions/workflows/deploy-chart.yaml) repo.

> Add new GCP Project IDs to that workflow's `project` input configuration

That workflow runs remote repos' `make deploy` while authenticated as a the privileged service account. It's SRE's responsibility to verify that the chart changes being applied have been properly reviewed.
