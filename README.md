
# 🏗️ Terraform AWS Infrastructure Setup

This project uses **Terraform** to provision a simple yet realistic AWS infrastructure, including a VPC, subnets, route tables, internet gateway, NAT gateway, and EC2 instances (one public, one private for database).

---

## 🚀 Overview

This Terraform configuration will create:

* 🌐 **VPC** — A custom virtual private cloud (`10.0.0.0/16`)
* 🟢 **Public Subnet** — For internet-facing resources
* 🔒 **Private Subnet** — For backend/database resources
* 🧱 **Internet Gateway (IGW)** — For outbound internet access
* 🔁 **NAT Gateway** — To allow the private subnet to reach the internet securely
* 🧰 **Security Group** — Allowing SSH (port 22)
* 💾 **EC2 Instances**

  * One in the **public subnet** (can SSH directly)
  * One in the **private subnet** (only accessible through NAT/public instance)
* 🔑 **Key Pair** — For SSH access
* 🛣️ **Route Tables** — Public and private routing for subnets

---

## 🧩 Folder Structure

```
terraform-aws-infra/
│
├── main.tf               # All infrastructure resources
├── variables.tf          # (Optional) Variables for customization
├── outputs.tf            # (Optional) Outputs for important data (like IPs)
├── README.md             # Project documentation (this file)
└── provider.tf           # AWS provider configuration
```

---

## ⚙️ Prerequisites

Before you begin, ensure you have:

1. **AWS Account**
   and **IAM user** with appropriate permissions (EC2, VPC, IAM, EIP, etc.).

2. **Terraform** installed
   Check with:

   ```bash
   terraform -version
   ```

3. **AWS CLI** configured
   Run:

   ```bash
   aws configure
   ```

   (You’ll need your `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and preferred region.)

4. **SSH Key Pair**
   Generate one if you don’t already have it:

   ```bash
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/mykey
   ```

   Copy the contents of `~/.ssh/mykey.pub` into your Terraform variable for `public_key`.

---

## 🪄 How to Use

### 1️⃣ Clone this repository

```bash
git clone https://github.com/yourusername/terraform-aws-infra.git
cd terraform-aws-infra
```

### 2️⃣ Update your configuration

Edit the `provider` block in your Terraform file:

```hcl
provider "aws" {
  region     = "us-east-1"
  access_key = "YOUR_ACCESS_KEY"
  secret_key = "YOUR_SECRET_KEY"
}
```

Also update:

* AMI IDs for your EC2 instances
* Your public SSH key in the `aws_key_pair` resource

---

### 3️⃣ Initialize Terraform

```bash
terraform init
```

This downloads all the required AWS provider plugins.

---

### 4️⃣ Validate configuration

```bash
terraform validate
```

Checks that your Terraform code is valid.

---

### 5️⃣ See what Terraform will create

```bash
terraform plan
```

---

### 6️⃣ Apply your configuration

```bash
terraform apply
```

Confirm with `yes` when prompted.
Terraform will now create your AWS infrastructure 🌩️

---

### 7️⃣ Destroy your infrastructure (when done)

To avoid unnecessary AWS charges:

```bash
terraform destroy
```

---

## 📦 Resources Created

| Resource Type          | Resource Name          | Description                        |
| ---------------------- | ---------------------- | ---------------------------------- |
| `aws_vpc`              | `myvpc`                | Virtual Private Cloud              |
| `aws_subnet`           | `public-subnet`        | Public subnet for app/EC2          |
| `aws_subnet`           | `private-subnet`       | Private subnet for DB              |
| `aws_internet_gateway` | `myigw`                | Internet access for public subnet  |
| `aws_nat_gateway`      | `my-nat`               | Internet access for private subnet |
| `aws_security_group`   | `mysg`                 | Allows SSH inbound traffic         |
| `aws_instance`         | `myinstance`           | Public EC2 instance                |
| `aws_instance`         | `db-instance`          | Private EC2 instance               |
| `aws_route_table`      | `public-rt`            | Routes via Internet Gateway        |
| `aws_route_table`      | `private-rt`           | Routes via NAT Gateway             |
| `aws_key_pair`         | `mykey`                | SSH key pair                       |
| `aws_eip`              | `nat-ip`, `myinstance` | Elastic IPs for NAT and EC2        |

---

## 🌐 Architecture Diagram

Here’s a simple flow of how everything connects:

```
                         ┌──────────────────────────┐
                         │        AWS VPC           │  (10.0.0.0/16)
                         │                          │
         ┌───────────────┴──────────────────────────┴───────────────┐
         │                                                          │
         │                                                          │
 ┌────────────┐                                          ┌────────────────┐
 │ Public Subnet│ (10.0.1.0/24)                          │ Private Subnet │ (10.0.2.0/24)
 │              │                                         │                │
 │  EC2 (App)   │ <──SSH──>                              │ EC2 (DB)       │
 │  "myinstance"│                                         │ "db-instance"  │
 │  [Elastic IP]│                                         │  (no public IP)│
 └──────┬───────┘                                         └──────┬─────────┘
        │                                                       │
        │                                                       │
   ┌────▼────┐                                              ┌────▼────┐
   │Internet │<───▶Internet Gateway (myigw)                  │ NAT GW  │ (my-nat)
   └─────────┘                                              └─────────┘
                                                                │
                                                                ▼
                                                       Internet access for DB
