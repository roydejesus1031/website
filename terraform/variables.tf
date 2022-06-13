variable "project_id" {
  type    = string
  default = "website-staging-9993433"
}

variable "github_repo" {
  type    = string
  default = "roydejesus1031/website"
}

variable "state_bucket_name" {
  type    = string
  default = "roy-dejesus-website-staging-tfstate"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-c"
}

variable "gh_site_deploy_pool_id" {
  type    = string
  default = "github-site-identity-pool"
}

variable "gh_site_deploy_prov_id" {
  type    = string
  default = "github-site-identity-provider"
}

variable "gh_tf_deploy_pool_id" {
  type    = string
  default = "github-tf-identity-pool"
}

variable "gh_tf_deploy_prov_id" {
  type    = string
  default = "github-tf-identity-provider"
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
}
