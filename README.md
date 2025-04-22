# 📊 WebCounter 

This project is a full-stack **Cloud Resume Challenge** implementation, designed to showcase cloud infrastructure and automation skills using AWS, Terraform, and GitHub Actions.

The static frontend is hosted on an S3 bucket and delivered globally via CloudFront. A dynamic visitor counter is powered by AWS Lambda, DynamoDB, and API Gateway. Infrastructure is fully managed with Terraform, and the CI/CD pipeline is handled via GitHub Actions.

---

## 🌐 Demo

🔗 [View Live Project](https://www.skillspheres.com)

## 🏗 About The Project

This app simulates a live resume website, counting how many people have visited using a **serverless backend**.

- **Frontend**: HTML, CSS, JS
- **Visitor Counter**: Python Lambda function triggered via API Gateway
- **Infrastructure**: Terraform
- **CI/CD**: GitHub Actions

---

## ⚙️ AWS Services Used

- 🧭 **Route 53** – DNS and custom domain hosting
- 🌍 **CloudFront** – Global CDN for frontend
- 📦 **S3** – Hosts static files
- 🔐 **Certificate Manager** – TLS/SSL certificates
- 🧠 **Lambda** – Visitor counter function in Python
- 🌐 **API Gateway** – Serves Lambda as a REST endpoint
- 🗃 **DynamoDB** – Stores visitor counts

---

## 🚀 Deployment Process

### 🖥 Frontend Deployment
Triggered by any changes in the `frontend/` folder:
- Uploads updated files to S3
- Invalidates CloudFront cache

### ⚙️ Backend Deployment
Triggered by changes to `.py`, `.zip`, or `Terraform/` files:
- Terraform Init + Plan
- Requires **manual approval** to continue
- Terraform Apply (provisions resources)
- Optional: Terraform Destroy (clean-up)