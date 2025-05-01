# AWS IAM Module  
**CreatedBy:** Pavan H  
**Date:** April 29, 2025  
**Email:** pavanh2000@outlook.com  

---

## Overview  
A Terraform module to automate the creation of **IAM Users**, **Groups**, **Policies**, and **Password Policies** using a structured YAML configuration file. This module simplifies IAM management by centralizing user/group definitions and aligning with AWS best practices:  
- Create individual IAM users.  
- Use AWS-managed policies whenever possible.  
- Assign permissions via groups for scalability.  

---

## Features  
- ✅ **YAML-driven Configuration**: Define users, groups, and policies in a single `users.yaml` file.  
- ⚙️ **Automated Resource Creation**:  
  - IAM Users with login profiles and access keys.  
  - IAM Groups with policy attachments.  
  - Password policies for account security.  
- 🔐 **Sensitive Data Handling**: Access keys, secrets, and passwords are marked as sensitive in outputs.  
- 📦 **Modular Design**: Easily extendable to support roles or service-specific policies.  

---

## Usage  

### Basic Example  
```hcl
module "iam" {
  source        = "github.com/yourusername/aws-iam-module?ref=v1.0.0"
  iam_data_file = "path/to/users.yaml"
  region        = "us-east-1"
}