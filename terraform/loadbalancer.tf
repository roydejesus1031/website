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

resource "google_compute_url_map" "website_http" {
  name = "website-static-http-redirect"
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

resource "google_compute_managed_ssl_certificate" "cert" {
  name = "website-cert"

  lifecycle {
    create_before_destroy = true
  }
  managed {
    domains = [var.website_url]
  }
}

resource "google_compute_target_https_proxy" "website_https" {
  name             = "website-proxy"
  url_map          = google_compute_url_map.website.id
  ssl_certificates = [google_compute_managed_ssl_certificate.cert.id]
}

resource "google_compute_target_http_proxy" "website_http" {
  name    = "website-proxy"
  url_map = google_compute_url_map.website_http.id
}

resource "google_compute_global_forwarding_rule" "website_https" {
  name       = "website-https"
  target     = google_compute_target_https_proxy.website_https.id
  port_range = 443
  ip_address = google_compute_global_address.website.id
}

resource "google_compute_global_forwarding_rule" "website_http" {
  name       = "website-http"
  target     = google_compute_target_http_proxy.website_http.id
  port_range = "80"
  ip_address = google_compute_global_address.website.id
}
