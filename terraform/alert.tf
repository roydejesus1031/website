resource "google_monitoring_notification_channel" "email" {
  display_name = "personal-email"
  type         = "email"
  labels = {
    email_address = var.email
  }
}

resource "google_monitoring_uptime_check_config" "website" {
  display_name = "website-uptime-check"
  timeout      = "15s"

  http_check {
    path         = "/"
    port         = "443"
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = var.website_url
    }
  }
}

# Alert policy on the uptime check itself doesn't exist in Terraform, have to make a
# separate alert policy like this
resource "google_monitoring_alert_policy" "alert_policy_uptime_check" {
  display_name = "website-uptime-alert"
  project      = var.project_id
  enabled      = true
  combiner     = "AND"

  conditions {
    display_name = "uptime-condition"
    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.label.\"check_id\"=\"${google_monitoring_uptime_check_config.website.uptime_check_id}\" AND resource.type=\"uptime_url\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"

      trigger {
        count = 1
      }
    }
  }
}
