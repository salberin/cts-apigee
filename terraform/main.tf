module "apigee" {
  source = "./modules/apigee"

  project_id = var.project_id
  env_name = var.env_name
}

module "loadbalancer" {
  source = "./modules/loadbalancer"

  project_id = var.project_id
  env_name = var.env_name
  external_ip = module.apigee.external_ip
  network = module.apigee.network
}
