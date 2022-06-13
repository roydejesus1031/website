terraform {
  backend "gcs" {
    bucket = "roy-dejesus-website-prod-tfstate"
    prefix = "terraform/state"
  }
}