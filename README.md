# 🌐 AWS Multi-AZ Web Server Deployment with Load Balancer (Terraform)

This project sets up a **highly available web infrastructure** on AWS using **Terraform**.

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

## 📁 Project Structure

```
aws-multi-az-webservers/
├── main.tf          # Main Terraform configuration
├── variables.tf     # AWS region and key pair input
├── outputs.tf       # ALB DNS output
├── README.md        # Project documentation
```

---

## 🚀 Getting Started

### 1. Clone This Repo

```bash
git clone https://github.com/YOUR_USERNAME/aws-multi-az-webservers.git
cd aws-multi-az-webservers
```

### 2. Set Variables

Edit `variables.tf`:

```hcl
variable "aws_region" {
  default = "us-east-1"
}

variable "key_name" {
  default = "your-key-name"
}
```

> Replace `"your-key-name"` with your actual EC2 Key Pair.

---

### 3. Deploy with Terraform

```bash
terraform init
terraform plan
terraform apply
```

> After deployment, Terraform will output the ALB DNS name.

---

## 🌐 Access the Web Servers

Open the ALB DNS in your browser:

```bash
http://<alb_dns_name>
```

You should see alternating messages from WebServer-A and WebServer-B.

---

## 🧹 Clean Up

To destroy the resources:

```bash
terraform destroy
```

---

## 🔐 Notes

- SSH is open to all IPs (`0.0.0.0/0`) – for production, restrict to your IP only.
- HTTPS is not configured – consider using ACM for SSL in real-world setups.

---

## 📄 License

MIT License. Free to use and modify.