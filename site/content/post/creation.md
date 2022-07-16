---
title: "How this site is built and deployed"
date: "2022-06-13"
author: "Roy De Jesus"
---

I will go over the build and deployment of this simple site, highlighting the decisions I took, why, and what I learned in the process.

My goals were to minimize costs while making an automated, secure, and easy to understand CI/CD process that would be easy to scale or make more complex systems with. I also wanted to learn some tools I was unfamiliar with, such as Terraform and Github Actions.

# Site
The html and css of this site was made using [Hugo](https://github.com/gohugoio/hugo), a static site generator. As I am not a web designer, I didn't want to spend too much time on the layout and just chose a theme that looked nice. The CI/CD process for the site can be seen [here](https://github.com/roydejesus1031/website/blob/main/.github/workflows/deploy-website.yml) and looks like this:

1. Code is pushed to the main branch of the repository.
2. Github Actions triggers a build, verifying that Hugo builds the site properly.
3. Using a Workload Identity, Github Actions fetches short-lived credentials for a Service Account with upload access to a Google Cloud Storage bucket.
4. The built static files are uploaded to the Cloud Storage bucket.

Since the actual deployment is just uploading the files to a public bucket, there is no downtime. There are also no sensitive secrets stored on Github. This is due to [Workload Identities](https://cloud.google.com/blog/products/identity-security/enabling-keyless-authentication-from-github-actions), which integrates with Github Actions to allow the repository and only the repository to fetch credentials with minimal scope that live for an hour.

# Infrastructure
The infrastructure that hosts the site is located on Google Cloud Platform. Since the site setup is so simple, the core infrastructure is only an https load balancer in front of a public bucket. The certificates, monitoring, and alerting, are also on GCP.

All of the GCP resources in the project is stored as [code](https://github.com/roydejesus1031/website/tree/main/terraform) and provisioned using Terraform. The Terraform provisioning itself is also part of the CI/CD pipeline, seen [here](https://github.com/roydejesus1031/website/blob/main/.github/workflows/deploy-infra.yml). The pipeline is very similar to the one that deploys the site and does the same thing with Workload Identities to get credentials.

# Difficulties of fully automating Terraform provisioning
What I initially wanted was a fully automated infrastructure provisioning CI/CD pipeline from start to finish. However, I ran into a couple issues that I think force the process to be partly manual:

1. The resources Github Actions uses to authenticate to GCP and use Terraform are itself made through Terraform.

It's a chicken and egg problem. Github Actions uses Workload Identities and Service Accounts in GCP that allow it to provision resources. But to do that, those resources need to first be created by Terraform. I had to manually provision the resources with Terraform first so Github Actions could use them.

2. To read the billing account attached to a GCP project in Terraform, an organizational role must be added to the Service Account.

This is only an issue for those who are using GCP as individuals. In order to add the GCP project resource to your Terraform files, it needs to read the billing account every time it runs as per the [documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project).

![Project billing account requirement](/images/terraform_billing.jpg 'Billing permissions required')

However, the roles needed for that like `roles/billing.viewer` are set at the Organization level, not at the Project level. So there is no way to give the Service Account the role it needs to do this outside an Organization. I had to remove the project resource in the Terraform definition and manually create it outside of Terraform.

3. The remote GCS backend for Terraform needs to create the bucket first to store the state inside it.

This is similar to the first problem. The `tfstate` needs to be stored remotely and securely since multiple CI runners require access. This is done through a remote bucket backend in GCP.

```hcl
terraform {
  backend "gcs" {
    bucket = "roy-dejesus-website-prod-tfstate"
    prefix = "terraform/state"
  }
}
```

However, the bucket is also defined in Terraform and needs to be created before Terraform can store state there. I had to manually remove the GCS backend first, apply Terraform to create the remote storage bucket, and then add the remote backend back.

4. Terraform either needs Owner privileges or roles manually added every time it interacts with a new resource.

> *The Principle of Least Privilege states that a subject should be given only those privileges needed for it to complete its task*<br>
> — <cite>Matt Bishop, Computer Security: Art and Science</cite>

I try to always follow this principle, so in the case of Github Actions using Terraform the Service Account needed roles to do things like create Cloud Storage buckets. But then I needed it to make load balancers, alerts, and so on. It obviously couldn't assign itself those permissions so I needed to manually step in every time it needed to manage a new resource.

# What else isn't automated?
The only remaining parts of the system are the domain itself and the DNS servers. I manually added the domain in Google Cloud Domains since it needed me to enter personal information such as my phone number and address.

As for the DNS servers, those live on Cloudflare. I could automate the provisioning of the records with Terraform but the Cloudflare provider only supported long-lived API keys instead of something similar to GCP's Workload Identity. That's why I opted not to but I might add it in the future anyway if I have time.

# Conclusion
Overall, the entire system is very low cost. While the domain has to be renewed yearly, almost everything else is within GCP, Cloudflare, or Github's free tiers.

The system can easily be extended without changing much of the CI/CD pipeline. I could make a complex web application, have Terraform provision a cluster in GKE, and then have the site deployment apply or install a helm chart. Tests could be added to the Github Action for deployment and reject failing commits.

The website might be simple, but I still ended up learning a lot about Terraform and Github Actions.

{{< css.inline >}}
<style>
li { color: #c7b658; }
</style>
{{< /css.inline >}}
