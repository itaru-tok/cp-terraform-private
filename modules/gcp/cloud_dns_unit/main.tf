resource "google_dns_managed_zone" "main" {
  dns_name   = "gcp-${var.env}.itaru.uk."
  name       = "gcp-${var.env}-itaru-uk"
  project    = var.project
  visibility = "public"
}

resource "google_dns_record_set" "main" {
  managed_zone = google_dns_managed_zone.main.name
  name         = "sm-api.gcp-${var.env}.itaru.uk."
  project      = var.project
  rrdatas      = ["34.54.231.91"] # TODO: 動的に設定する場合は要修正
  ttl          = 300
  type         = "A"
}
