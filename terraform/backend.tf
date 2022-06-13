terraform {
  backend "gcs" {
    bucket  = "roy-dejesus-website-staging-tfstate"
    prefix  = "terraform/state"
  }
}