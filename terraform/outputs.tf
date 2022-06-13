output "site_deployer_provider_id" {
  value     = "projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.gh_site_deploy_pool_id}/providers/${var.gh_site_deploy_prov_id}"
  sensitive = true
}

output "site_deployer_svc_acc" {
  value     = google_service_account.site_deployer.email
  sensitive = true
}

output "tf_deployer_provider_id" {
  value     = "projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.gh_tf_deploy_pool_id}/providers/${var.gh_tf_deploy_prov_id}"
  sensitive = true
}

output "tf_deployer_svc_acc" {
  value     = google_service_account.tf_deployer.email
  sensitive = true
}