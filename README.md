# Reference project infrastructure

This repository provisions all cloud infrastructure required by client projects.

## Pre-requisites

Complete the steps in [this Notion Doc](https://www.notion.so/dapperlabs/Gen3-Infrastructure-project-setup-b5bdeed6bec64158ae75547e15620fa9) before creating new environments using this repo.

## Terraform

The `terraform` folder contains one folder per environment. Each environment maps to different GCP project, keeping the infrastructure definition and its provisioning isolated from one another.

In order to create a new environment, make a copy of an existing environment folder, update `terraform.auto.tfvars` and add an entry to `atlantis.yaml`. The pull request with these changes will trigger a terraform plan to create the new project and resources.

## Kubernetes

The `k8s` folder has cluster-wide helm charts that can be applied by running `make deploy [ENVIRONMENT=...]`.

## CI/CD

Github actions workflows are defined under `./.github/workflows`.
