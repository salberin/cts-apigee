resource "google_project_service" "apigee" {
  project = var.project_id
  service = "apigee.googleapis.com"
}

resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "servicenetworking" {
  project = var.project_id
  service = "servicenetworking.googleapis.com"
}

resource "google_compute_network" "apigee_network" {
  name       = "apigee-network"
  project    = var.project_id
  depends_on = [google_project_service.compute]
}

resource "google_compute_global_address" "apigee_external_ip" {
  name = "apigee-${var.env_name}-ext-ip"
  project = var.project_id
}

resource "google_compute_global_address" "apigee_range" {
  name          = "apigee-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.apigee_network.id
  project       = var.project_id
}

resource "google_service_networking_connection" "apigee_vpc_connection" {
  network                 = google_compute_network.apigee_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.apigee_range.name]
  depends_on              = [google_project_service.servicenetworking]
}

resource "google_apigee_organization" "apigee_org" {
  analytics_region   = var.region
  project_id         = var.project_id
  authorized_network = google_compute_network.apigee_network.id
  billing_type       = var.apigee_billing_type
  retention          = "DELETION_RETENTION_UNSPECIFIED"
  depends_on         = [
    google_service_networking_connection.apigee_vpc_connection,
    google_project_service.apigee,
  ]
}

resource "google_apigee_addons_config" "demo_organization" {
  org = google_apigee_organization.apigee_org.name

  addons_config {
    api_security_config {
      enabled = true
    }
    monetization_config {
      enabled = true
    }
  }
}

resource "google_apigee_instance" "apigee_ins" {
  name     = "${var.env_name}-instance"
  location = var.region
  org_id   = google_apigee_organization.apigee_org.id
}

resource "google_apigee_environment" "apigee_env" {
  org_id   = google_apigee_organization.apigee_org.id
  name         = "${var.env_name}-environment"
  description  = "Apigee Environment"
  display_name = "environment-1"
}

resource "google_apigee_instance_attachment" "apigee_ins_att" {
  instance_id  = google_apigee_instance.apigee_ins.id
  environment  = google_apigee_environment.apigee_env.name
}

resource "google_apigee_envgroup" "apigee_envgroup" {
  org_id    = google_apigee_organization.apigee_org.id
  name      = "${var.env_name}-envgroup"
  hostnames = ["${google_compute_global_address.apigee_external_ip.address}.nip.io"]
  depends_on = [ google_compute_global_address.apigee_external_ip ]
}

resource "google_apigee_envgroup_attachment" "apigee_envgroup_att" {
  envgroup_id  = google_apigee_envgroup.apigee_envgroup.id
  environment  = google_apigee_environment.apigee_env.name
}
