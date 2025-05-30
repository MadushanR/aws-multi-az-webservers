# 🚀 AWS Multi-AZ Web Server Deployment with Terraform + Jenkins CI

This project provisions a highly available infrastructure on AWS using Terraform, and automates provisioning and destruction using Jenkins.

---

## ✅ What This Project Deploys

- A custom **VPC** (`10.0.0.0/16`)
- Two **public subnets** in different AZs (`us-east-1a`, `us-east-1b`)
- Two **EC2 instances** running Apache web servers
- An **Internet Gateway** and public **Route Table**
- A **Security Group** allowing HTTP (80) and SSH (22)
- An **Internet-facing Application Load Balancer (ALB)**

---

## 📐 Architecture Diagram

```
           [Internet]
                |
     -------------------------
    |                         |
[ Application Load Balancer (ALB) ]
    |                         |
[EC2 in AZ-a]           [EC2 in AZ-b]
```

---

## 🧰 Prerequisites

### Tools

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Jenkins](https://www.jenkins.io/download/) installed and running on Windows
- AWS account with IAM user and Access/Secret keys
- EC2 Key Pair already created in your AWS region

---

## 📁 Project Structure

```
aws-multi-az-webservers/
├── main.tf          # Main Terraform configuration
├── variables.tf     # AWS region and key pair
├── outputs.tf       # Output the ALB DNS name
├── README.md        # Documentation
```
---

## 🚀 Getting Started

### Clone This Repo

```bash
git clone https://github.com/MadushanR/aws-multi-az-webservers.git
cd aws-multi-az-webservers
```
---

## ⚙️ Terraform Usage

### 1. Configure Variables

Edit `variables.tf`:

```hcl
variable "aws_region" {
  default = "us-east-1"
}

variable "key_name" {
  default = "your-key-name"
}
```

> Replace `your-key-name` with your EC2 Key Pair name.

### 2. Run Manually (Optional)

```bash
terraform init
terraform plan
terraform apply
```

---

## 🔄 Jenkins Automation (Windows Setup)

### ✅ Jenkins Job Steps

1. Create a **Freestyle Project**
2. Check **"This project is parameterized"**
   - Add `Choice Parameter`: `ACTION` with values `apply` and `destroy`
3. Add **Build Step** → "Execute Windows batch command"

### 📜 Jenkins Script

```bat
set AWS_ACCESS_KEY_ID=YOUR_KEY_ID
set AWS_SECRET_ACCESS_KEY=YOUR_SECRET_KEY
set AWS_DEFAULT_REGION=us-east-1

cd `PATH_TO_TERRAFORM FILES`

terraform init -input=false
terraform plan -out=tfplan

IF "%ACTION%"=="apply" (
    terraform apply -auto-approve
) ELSE IF "%ACTION%"=="destroy" (
    terraform destroy -auto-approve
) ELSE (
    echo Invalid ACTION: %ACTION%
    exit /b 1
)
```

> Replace `YOUR_KEY_ID` and `YOUR_SECRET_KEY` or use Jenkins credentials securely.

---

### 🔐 Secure Credential Option (Recommended)

Use Jenkins "Credentials" plugin:

1. Add `aws-access-key-id` and `aws-secret-access-key` as **Secret Text**
2. Bind these to environment variables in the job
3. Modify batch script to use those variables

---

## 🌐 Access the Web Server

After deployment:

```bash
terraform output alb_dns_name
```

Paste the DNS URL in your browser to access the load-balanced Apache servers.

---

## 🧹 Cleanup

In Jenkins, choose:
- `ACTION = destroy`
- Run the job to tear down infrastructure

Or manually:

```bash
terraform destroy
```

---

## 📜 License

MIT License. Free to use and modify.