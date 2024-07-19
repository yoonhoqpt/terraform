# -------------------------------------------
# Shared infrastructure variables and secrets
# -------------------------------------------

variable "billing_account_id" {
  description = "Billing account to associate the project with"
  type        = string
}

variable "folder_id" {
  description = "Folder or project to create this project under"
  type        = string
}

variable "environment" {
  description = "Environment this stack will be used for. One of development, staging or production"
  type        = string
}

variable "project_name" {
  description = "Name of the GCP project to create and associate this infrastructure with"
  type        = string
}

variable "product_name" {
  description = "Name of the product this infrastructure will support"
  type        = string
}

variable "product_friendly_name" {
  description = "Friendly name of the product this infrastructure will support"
  type        = string
}

variable "cluster_network_name" {
  description = "Name of the cluster network to create"
  type        = string
  default     = "gke-application-cluster-vpc"
}

variable "default_region" {
  description = "Region the initial cluster and databases will be deployed to"
  type        = string
}
