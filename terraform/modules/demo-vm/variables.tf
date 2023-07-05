variable "project_id" {
  description = "Project ID for the project to create the Apigee instance in"
  type = string
}

variable "region" {
  description = "Region where the instance runtime and analytics data will live"
  default = "europe-west1"
}

variable "instance_name" {
  description = "Name of the Apigee instance"
  default = "my-instance-name"
}

variable "env_name" {
  default = "demo"
  description = "Basename for the environment"
}

variable "env_group_name" {
  description = "Name for the environment group of the instance"
  default = "my-env-group"
}

variable "apigee_billing_type" {
  description = "Type of Apigee Instance to create"
  default = "EVALUATION"
}
