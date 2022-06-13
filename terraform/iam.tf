resource "google_service_account" "tf_deployer" {
  project    = var.project_id
  account_id = "terraform-deployer"
}

resource "google_project_iam_member" "tf_deployer" {
  for_each = toset([
    "roles/storage.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/compute.loadBalancerAdmin",
    "roles/iam.workloadIdentityPoolAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/monitoring.admin"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.tf_deployer.email}"
}

module "gh_tf_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id  = var.project_id
  pool_id     = var.gh_tf_deploy_pool_id
  provider_id = var.gh_tf_deploy_prov_id

  sa_mapping = {
    (google_service_account.tf_deployer.account_id) = {
      sa_name   = google_service_account.tf_deployer.name
      attribute = "attribute.repository/${var.github_repo}"
    }
  }
}

resource "google_service_account" "site_deployer" {
  project    = var.project_id
  account_id = "site-deployer"
}

resource "google_project_iam_member" "site_deployer" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.site_deployer.email}"

  condition {
    title      = "Website Access Only"
    expression = "resource.name.startsWith(\"projects/_/buckets/${google_storage_bucket.website.name}\")"
  }
}

module "gh_site_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id  = var.project_id
  pool_id     = var.gh_site_deploy_pool_id
  provider_id = var.gh_site_deploy_prov_id

  sa_mapping = {
    (google_service_account.site_deployer.account_id) = {
      sa_name   = google_service_account.site_deployer.name
      attribute = "attribute.repository/${var.github_repo}"
    }
  }
}

resource "google_storage_bucket_iam_binding" "public" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers",
  ]
}
