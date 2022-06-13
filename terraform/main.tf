provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  user_project_override = true
}

data "google_billing_account" "acct" {
  display_name = var.billing_acct
  open         = true
}

resource "google_project" "project" {
  name            = var.project_name
  project_id      = var.project_id
  billing_account = data.google_billing_account.acct.id
}

resource "google_project_service" "services" {
  for_each = toset(var.services)

  project                    = var.project_id
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false

  depends_on = [google_project.project]
}

resource "google_service_account" "tf_deployer" {
  project    = var.project_id
  account_id = "terraform-deployer"
}

resource "google_project_iam_member" "tf_deployer" {
  project = var.project_id
  role    = "roles/storage.admin"
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

resource "google_storage_bucket" "website" {
  name                        = "roy-dejesus-website-staging"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404/index.html"
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
    title = "Website Access Only"
    expression  = "resource.name.startsWith(\"projects/_/buckets/${google_storage_bucket.website.name}\")"
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

resource "google_compute_global_address" "website" {
  name = "website-static"
}

resource "google_compute_backend_bucket" "website" {
  name        = "website-backend"
  bucket_name = google_storage_bucket.website.name
}

resource "google_compute_url_map" "website" {
  name            = "website-static-lb"
  default_service = google_compute_backend_bucket.website.id
}

resource "google_compute_target_http_proxy" "website" {
  name    = "website-proxy"
  url_map = google_compute_url_map.website.id
}

resource "google_compute_global_forwarding_rule" "website" {
  name       = "website-static"
  target     = google_compute_target_http_proxy.website.id
  port_range = "80"
  ip_address = google_compute_global_address.website.id
}

resource "google_storage_bucket" "tf_state" {
  name          = "roy-dejesus-website-staging-tfstate"
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}