# Outputs
output "url_slack_metrics_api" {
  value = google_cloud_run_service.slack_metrics_api.status[0].url
}
