terraform {
  required_version = "~> 1.3"
  required_providers {
    google-beta = {
      source = "hashicorp/google-beta"
      version = "~> 5.2.0"
    }
  }
}
