# Cisco Modeling Labs (CML) — AWS Terraform Lab

Terraform project for deploying the AWS infrastructure required to run **Cisco Modeling Labs (CML)** for a CCNP Enterprise / Cisco SD-WAN lab.

The target infrastructure is designed around an AWS **C8i.8xlarge** instance with:

* 32 vCPU
* 64 GiB RAM
* x86_64 architecture
* Nested virtualization enabled
* 200 GB gp3 EBS storage
* AWS Canada Central (`ca-central-1`)

> **Important:** This repository does not contain Cisco CML software or Cisco reference-platform images. Those must be obtained through the appropriate Cisco licensing/entitlement process.

---

# 1. What This Project Does

The Terraform project will eventually provision the AWS infrastructure required for the CML lab:

```text
AWS Account
    │
    ├── VPC
    │   └── 10.0.0.0/16
    │
    ├── Internet Gateway
    │
    ├── Public Subnet
    │   └── 10.0.1.0/24
    │
    ├── Route Table
    │
    ├── Security Group
    │
    ├── IAM
    │
    ├── S3
    │
    └── EC2
        └── C8i.8xlarge
            ├── 32 vCPU
            ├── 64 GiB RAM
            ├── 200 GB gp3
            └── Nested Virtualization
                    │
                    ▼
                   CML
                    │
        ┌───────────┼───────────┐
        │           │           │
     Routers     Switches     SD-WAN
```

The project is being built in stages so that the infrastructure can be reviewed before resources are created.

---

# 2. Repository Structure

```text
cml-aws-lab/
│
├── README.md
├── .gitignore
├── run-terraform.sh
│
└── infrastructure/
    ├── versions.tf
    ├── provider.tf
    ├── variables.tf
    ├── terraform.tfvars.example
    ├── main.tf
    └── outputs.tf
```

Additional Terraform files will be added as the AWS infrastructure is built.

---

# 3. Prerequisites

Before starting, make sure the following are available on the machine that will run Terraform.

## Required

* Git
* AWS CLI
* Terraform >= 1.15
* Bash
* Access to the AWS account
* AWS IAM Identity Center / SSO configured for the account

Verify Git:

```bash
git --version
```

Verify AWS CLI:

```bash
aws --version
```

Verify Terraform:

```bash
terraform version
```

Verify Bash:

```bash
bash --version
```

---

# 4. AWS Authentication

AWS credentials should **not** be stored in this repository.

Do not add:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
```

to Terraform files or commit them to Git.

The recommended authentication method for this project is **AWS IAM Identity Center (SSO)**.

AWS documentation:

https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html

---

# 5. Configure AWS SSO

If AWS SSO / IAM Identity Center has already been configured by your AWS administrator, configure the AWS CLI on your machine.

Run:

```bash
aws configure sso
```

Follow the prompts.

You will be asked for information such as:

```text
SSO session name
SSO start URL
SSO region
```

Then select:

```text
AWS Account
    ↓
AWS account
    ↓
Permission Set / Role
```

When prompted for the profile name, use something recognizable, for example:

```text
cml-lab
```

---

# 6. Login to AWS

After the SSO profile has been configured:

```bash
aws sso login --profile cml-lab
```

A browser window should open and ask you to authenticate.

After successful authentication, verify access:

```bash
aws sts get-caller-identity --profile cml-lab
```

You should receive output similar to:

```json
{
    "UserId": "...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:..."
}
```

Make sure this is the AWS account where the CML lab should be deployed.

---

# 7. Set the AWS Profile

Set the AWS profile for the current terminal session.

## Linux / macOS / Git Bash

```bash
export AWS_PROFILE=cml-lab
```

## PowerShell

```powershell
$env:AWS_PROFILE="cml-lab"
```

Verify:

```bash
aws sts get-caller-identity
```

You should now be able to run the command without specifying:

```text
--profile cml-lab
```

Terraform will use the same AWS authentication.

---

# 8. Clone the Repository

Clone this repository to the machine that will run Terraform.

Replace the URL below with the actual repository URL:

```bash
git clone <YOUR_REPOSITORY_URL>
```

For example:

```bash
git clone https://github.com/YOUR_USERNAME/cml-aws-lab.git
```

Move into the repository:

```bash
cd cml-aws-lab
```

Verify:

```bash
git status
```

---

# 9. Configure Terraform Variables

Move into the Terraform directory:

```bash
cd infrastructure
```

Copy the example Terraform variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

On Windows PowerShell:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

---

# 10. Edit `terraform.tfvars`

Open:

```text
infrastructure/terraform.tfvars
```

Example:

```hcl
aws_region   = "ca-central-1"

project_name = "cml-aws-lab"
environment  = "lab"

vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"

instance_type    = "c8i.8xlarge"
root_volume_size = 200

allowed_management_cidr = "YOUR.PUBLIC.IP/32"
```

Replace:

```text
YOUR.PUBLIC.IP
```

with the public IPv4 address that should be allowed to access the CML management interface.

For example:

```hcl
allowed_management_cidr = "203.0.113.25/32"
```

The `/32` restricts access to that single IPv4 address.


---

# 11. Find Your Public IP

You can use:

```bash
curl https://checkip.amazonaws.com
```

or:

```bash
curl https://api.ipify.org
```

Example:

```text
203.0.113.25
```

Then configure:

```hcl
allowed_management_cidr = "203.0.113.25/32"
```

---

# 12. Terraform Workflow Script

The repository contains:

```text
run-terraform.sh
```

The script automatically changes into the Terraform infrastructure directory and runs the standard Terraform workflow.

Current script:

```bash
#!/bin/bash
set -euo pipefail

# Change to the infrastructure directory where Terraform configuration lives.

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Running Terraform steps in: $(pwd)"

terraform init
terraform validate
terraform fmt
terraform validate
terraform plan
terraform output

echo "Terraform workflow complete."
```

The script does **not** run `terraform apply`.

This is intentional.

The first execution should only initialize, validate, format, and generate the Terraform plan.

---
# AWS Cost Protection

This project creates an AWS monthly cost budget.

The default budget is:

```text
$80 USD / month

# 13. Make the Script Executable

From the repository root:

```bash
chmod +x run-terraform.sh
```

Then run:

```bash
./run-terraform.sh
```

Alternatively:

```bash
bash run-terraform.sh
```

---

# 14. What the Script Does

The script runs:

### Terraform initialization

```bash
terraform init
```

Downloads the required Terraform providers and initializes the working directory.

### Terraform validation

```bash
terraform validate
```

Checks that the Terraform configuration is syntactically and structurally valid.

### Terraform formatting

```bash
terraform fmt
```

Formats the Terraform files.

### Validation again

```bash
terraform validate
```

Confirms that formatting did not introduce any issues.

### Terraform plan

```bash
terraform plan
```

Shows what Terraform intends to create, modify, or destroy.

### Terraform output

```bash
terraform output
```

Displays Terraform outputs from the current state.

---

# 15. Review the Terraform Plan

**Do not immediately run `terraform apply`.**

First review:

```bash
terraform plan
```

Make sure the plan contains only resources that are expected.

As this project develops, the plan will eventually include resources such as:

```text
VPC
Internet Gateway
Subnet
Route Table
Security Group
IAM Role
S3 Bucket
EC2 Instance
EBS Volume
Elastic IP
```

The final infrastructure will also include the configuration necessary for CML and nested virtualization.

---

# 16. Deploy the Infrastructure

Once the Terraform plan has been reviewed:

```bash
terraform apply
```

Terraform will ask for confirmation.

Type:

```text
yes
```

to proceed.

Alternatively:

```bash
terraform apply -auto-approve
```

can be used, but this is **not recommended for the first deployment**.

Always review the plan before the first deployment.

---

# 17. Destroy the Infrastructure

When the lab is no longer needed:

```bash
terraform destroy
```

Terraform will display the resources that will be removed.

Confirm with:

```text
yes
```

> Be careful with `terraform destroy`. Any resources managed by this Terraform project may be removed.

---

# 18. AWS Cost Considerations

The CML EC2 instance is intended to be used as a lab environment.

The target instance is:

```text
c8i.8xlarge
32 vCPU
64 GiB RAM
```

Running it 24/7 can result in significant AWS charges.

For a study lab, consider stopping the EC2 instance when it is not being used.

However, be aware that stopping the instance does not eliminate all AWS charges. EBS storage and other resources may continue to incur charges.

---

# 19. Security

The Terraform project intentionally does not store AWS credentials.

Do not commit:

```text
AWS access keys
AWS secret keys
AWS session tokens
SSH private keys
Cisco software packages
Cisco reference-platform images
terraform.tfstate
terraform.tfvars
```

The `.gitignore` file is configured to prevent many of these files from being committed accidentally.

Before pushing changes to Git, check:

```bash
git status
```

---

# 20. Current Deployment Architecture

The target architecture is:

```text
                    Internet
                       │
                       │
                Internet Gateway
                       │
              ┌────────▼────────┐
              │      VPC        │
              │   10.0.0.0/16   │
              │                 │
              │ Public Subnet   │
              │  10.0.1.0/24    │
              │       │         │
              │       ▼         │
              │  C8i.8xlarge    │
              │                 │
              │  32 vCPU        │
              │  64 GiB RAM     │
              │  200 GB gp3     │
              │                 │
              │  Nested VM      │
              │  virtualization │
              └─────────────────┘
```

CML will run inside the EC2 environment and will host the Cisco virtual network devices.

---

# 21. Planned CML Lab

The final lab is intended to support CCNP Enterprise and Cisco SD-WAN study.

Potential nodes include:

```text
Catalyst 9000v
Catalyst 8000v
ISR / IOS-XE routers
CSR1000v
SD-WAN Edge
SD-WAN Controller
SD-WAN Manager
SD-WAN Validator
```

The exact CML topology will be created separately from the AWS infrastructure.

---

# 22. Development Roadmap

The project will be developed in stages.

```text
[1] Terraform foundation
        │
        ▼
[2] AWS VPC / Networking
        │
        ▼
[3] Security Groups
        │
        ▼
[4] IAM
        │
        ▼
[5] S3 / CML image storage
        │
        ▼
[6] C8i.8xlarge EC2
        │
        ▼
[7] Nested virtualization
        │
        ▼
[8] CML installation
        │
        ▼
[9] CML reference-platform images
        │
        ▼
[10] CML Terraform provider
        │
        ▼
[11] CCNP Enterprise topology
        │
        ▼
[12] Cisco SD-WAN topology
```

---

# 23. Important: Cisco Licensing

Cisco CML software and reference-platform images are not included in this repository.

The user deploying CML is responsible for obtaining the required Cisco software and licensing through the appropriate Cisco channels.

Do not commit Cisco software images to this Git repository.

---

# 24. Quick Start

For an experienced user, the complete workflow is:

```bash
# 1. Configure AWS SSO
aws configure sso

# 2. Login
aws sso login --profile cml-lab

# 3. Select AWS profile
export AWS_PROFILE=cml-lab

# 4. Clone repository
git clone <YOUR_REPOSITORY_URL>

# 5. Enter repository
cd cml-aws-lab

# 6. Configure variables
cp infrastructure/terraform.tfvars.example \
   infrastructure/terraform.tfvars

# 7. Edit terraform.tfvars

# 8. Run Terraform workflow
chmod +x run-terraform.sh
./run-terraform.sh

# 9. Review the plan

# 10. Deploy
cd infrastructure
terraform apply
```

---

# 25. Support / Troubleshooting

Check AWS authentication:

```bash
aws sts get-caller-identity
```

Check Terraform:

```bash
terraform version
```

Reinitialize Terraform:

```bash
terraform init -upgrade
```

Format Terraform:

```bash
terraform fmt -recursive
```

Validate Terraform:

```bash
terraform validate
```

Generate a plan:

```bash
terraform plan
```

Check Terraform state:

```bash
terraform state list
```

Check Git status:

```bash
git status
```

---

## Current Status

The project is currently in the **Terraform foundation phase**.

The next development stage is:

```text
Terraform
    │
    ▼
AWS VPC
    │
    ├── 10.0.0.0/16
    │
    ├── Internet Gateway
    │
    ├── Public Subnet
    │      └── 10.0.1.0/24
    │
    ├── Route Table
    │
    └── Security Group
```

Once networking is complete, the EC2/CML infrastructure will be added.
