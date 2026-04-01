output "id_db_cloud_pratica_host" {
  value = google_secret_manager_secret.db_cloud_pratica_host.id
}

output "id_db_slack_metrics_user" {
  value = google_secret_manager_secret.db_slack_metrics_user.id
}

output "id_db_slack_metrics_password" {
  value = google_secret_manager_secret.db_slack_metrics_password.id
}
