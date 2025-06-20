#  Terraform Static Website Hosting (S3 + CloudFront + HTTPS)

This project deploys a **fully static website** to **Amazon S3**, secured and distributed via **CloudFront**, using **Terraform**. 
Everything runs on AWS **free tier**.

---

##  Features

-  Hosts static files in an S3 bucket
-  Secured with HTTPS via CloudFront
-  Publicly accessible via a `cloudfront.net` URL
-  Automatically redirects HTTP → HTTPS
-  No custom domain or payments required
-  Uploads HTML, CSS, JS, and images
-  Versioning and public access configured
-  Infrastructure as Code via Terraform

---

##  Requirements

- [Terraform](https://developer.hashicorp.com/terraform/install)
- AWS CLI configured with a user that has:
  - `s3:*`
  - `cloudfront:*`
  - `iam:PassRole` (for advanced CloudFront features)

---

##  Project Structure

├── main.tf                     # Terraform infrastructure (S3 + CloudFront)
├── variables.tf 
├── providers .tf
├── terraform.tfvars
├── index.html                  # Website homepage
├── error.html
├── NextWork - Everyone should be in a job they love_files/ # CSS, JS, images
├── LICENSE
└── README.md                   # This file
