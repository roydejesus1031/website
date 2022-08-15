resource "google_storage_bucket" "tf_state" {
  name          = var.state_bucket_name
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }
  lifecycle_rule {
    condition {
      num_newer_versions = 5
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket" "website" {
  name                        = var.website_url
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404/index.html"
  }
}
