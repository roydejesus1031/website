provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  user_project_override = true
}

data "google_project" "project" {
}

resource "google_project_service" "services" {
  for_each = toset(var.services)

  project                    = var.project_id
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false
}
