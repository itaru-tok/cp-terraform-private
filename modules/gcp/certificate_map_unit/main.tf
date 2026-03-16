resource "google_certificate_manager_certificate_map" "main" {
  name    = "cloud-pratica-${var.env}"
  project = var.project
}

resource "google_certificate_manager_certificate_map_entry" "main" {
  certificates = ["projects/672056542792/locations/global/certificates/gcp-${var.env}-itaru-uk-global"]
  hostname     = "*.gcp-${var.env}.itaru.uk"
  map          = google_certificate_manager_certificate_map.main.name
  name         = "gcp-${var.env}-itaru-uk-global"
  project      = var.project
}
