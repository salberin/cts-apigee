variable "project_id" {
  description = "Project ID for the project to create the Apigee instance in"
  type = string
}

variable "region" {
  description = "Region where the instance runtime and analytics data will live"
  default = "europe-west1"
}

variable "env_name" {
  default = "demo"
  description = "Basename for the environment"
}
