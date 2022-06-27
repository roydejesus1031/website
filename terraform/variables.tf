variable "project_id" {
  type        = string
  default     = "website-353206"
  description = "GCP Project ID"
}

variable "github_repo" {
  type        = string
  default     = "roydejesus1031/website"
  description = "Github repo to allow the workload identity for"
}

variable "state_bucket_name" {
  type        = string
  default     = "roy-dejesus-website-prod-tfstate"
  description = "Remote GCP storage bucket for state"
}

variable "website_url" {
  type        = string
  default     = "roydejesus.com"
  description = "URL for website"
}

variable "email" {
  type        = string
  default     = "roydejesus1031@gmail.com"
  description = "Email to notify for alerts"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region"
}

variable "zone" {
  type        = string
  default     = "us-central1-c"
  description = "GCP zone"
}

variable "gh_site_deploy_pool_id" {
  type        = string
  default     = "github-site-identity-pool"
  description = "ID for identity pool for site deployment used by Github"
}

variable "gh_site_deploy_prov_id" {
  type        = string
  default     = "github-site-identity-provider"
  description = "ID for identity provider for site deployment used by Github"
}

variable "gh_tf_deploy_pool_id" {
  type        = string
  default     = "github-tf-identity-pool"
  description = "ID for identity pool for Terraform used by Github"
}

variable "gh_tf_deploy_prov_id" {
  type        = string
  default     = "github-tf-identity-provider"
  description = "ID for identity provider for Terraform used by Github"
}

variable "services" {
  type = list(any)
  default = [
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "cloudbilling.googleapis.com",
    "compute.googleapis.com",
    "iamcredentials.googleapis.com"
  ]
  description = "GCP services that need to be enabled"
}
