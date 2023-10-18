resource "google_compute_region_network_endpoint_group" "apigee_neg" {
  name                  = "${var.env_name}-neg"
  region                = var.region
  project = var.project_id

  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = var.service_attachment

  network               = var.network
}


resource "google_compute_backend_service" "apigee_backend" {
  name          = "apigee-${var.env_name}-backend"
  project = var.project_id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol = "HTTPS"

  backend {
    group = google_compute_region_network_endpoint_group.apigee_neg.id
  }
}

resource "google_compute_url_map" "apigee_url_map" {
  name        = "apigee-${var.env_name}-url-map"
  description = "a description"
  project = var.project_id
  default_service = google_compute_backend_service.apigee_backend.id
}

resource "google_compute_managed_ssl_certificate" "apigee_ext_cert" {
  name = "apigee-${var.env_name}-cert"
  project = var.project_id
  managed {
    domains = ["${var.external_ip}.nip.io."]
  }
}

resource "google_compute_target_https_proxy" "apigee_target_proxy" {
  name             = "apigee-${var.env_name}-target-proxy"
  project = var.project_id
  url_map          = google_compute_url_map.apigee_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.apigee_ext_cert.id]
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "apigee-${var.env_name}-forwarding-rule"
  target     = google_compute_target_https_proxy.apigee_target_proxy.id
  port_range = 443
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address = var.external_ip
  project = var.project_id
}
