# Website

This is a simple personal website built using Hugo. The more interesting part is the CI/CD process. Nearly the entire thing, from the cloud infrastructure on GCP to the actual static files, is kept as code in this repo and automatically deployed on any change. It uses Terraform, Github Actions, and GCP services like Workload Identity for this.
