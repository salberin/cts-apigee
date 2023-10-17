output "service_attachment" {
  value = "${google_apigee_instance.apigee_ins.service_attachment}"
}

output "hostname" {
  value = "${google_compute_global_address.apigee_external_ip.address}.nip.io"
}

output "external_ip" {
  value = "${google_compute_global_address.apigee_external_ip.address}"
}

output "network" {
  value = google_compute_network.apigee_network.id
}
