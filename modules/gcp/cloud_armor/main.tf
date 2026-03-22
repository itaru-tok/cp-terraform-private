resource "google_compute_security_policy" "cloud_pratica_backend" {
  name    = "cloud-pratica-backend-${var.env}"
  project = var.project

  lifecycle {
    ignore_changes = all
  }
}
