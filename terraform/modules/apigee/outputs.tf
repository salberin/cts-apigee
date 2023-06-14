output "service_attachment" {
  value = "${google_apigee_instance_attachment.apigee_ins_att.id}"
}

output "hostname" {
  value = "${google_compute_global_address.apigee_external_ip.address}.nip.io"
}

output "external_ip" {
  value = "${google_compute_global_address.apigee_external_ip.address}"
}
