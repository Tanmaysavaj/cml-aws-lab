# Cisco Modeling Labs (CML) — AWS Terraform Lab

Terraform project for creating the AWS infrastructure required to run Cisco Modeling Labs (CML).

Terraform creates the AWS VM, basic networking, security, SSH access, and monthly cost budget.

**CML itself is installed separately by the user.**

---

## 1. Target Configuration

The lab uses:

| Resource | Configuration |
|---|---|
| AWS Region | `ca-central-1` |
| EC2 Instance | `c8i.8xlarge` |
| CPU | 32 vCPU |
| Memory | 64 GiB |
| Architecture | x86_64 |
| Nested Virtualization | Enabled |
| Storage | 200 GB gp3 |
| Monthly Budget | USD 80 |

---

## 2. AWS Resources Created

```text
AWS Account
│
├── Monthly Budget
│
├── VPC
│   └── 10.0.0.0/16
│
├── Public Subnet
│   └── 10.0.1.0/24
│
├── Internet Gateway
│
├── Route Table
│
├── Security Group
│   ├── TCP 443 → Management IP
│   └── TCP 22  → Management IP
│
├── SSH Key Pair
│
└── EC2
    └── c8i.8xlarge
        ├── 32 vCPU
        ├── 64 GiB RAM
        ├── 200 GB gp3
        └── Nested Virtualization
```

The Cisco lab topology, routers, switches, SD-WAN nodes, tunnels, and CML configuration are managed inside CML.

### Repository Structure

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
    ├── budget.tf
    ├── networking.tf
    ├── security.tf
    ├── cml.tf
    └── outputs.tf
```

## 3. Prerequisites

Install:

- Git
- AWS CLI v2
- Terraform 1.15+
- Bash

Installation links:

- AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- Terraform: https://developer.hashicorp.com/terraform/install
- Git: https://git-scm.com/downloads

Verify:

```bash
git --version
aws --version
terraform version
bash --version
```

If using Windows, run the Terraform script from Git Bash.

## 4. AWS Access

The AWS account must have IAM Identity Center / SSO configured.

You will need an AWS permission set that allows Terraform to create:

- VPC resources
- EC2 resources
- Security Groups
- Key Pairs
- AWS Budgets

AWS SSO documentation:

https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html

## 5. Configure AWS SSO

Run:

```bash
aws configure sso
```

Follow the prompts.

When asked for the profile name, use:

```text
cml-lab
```

Select the AWS account and permission set that should be used for the CML lab.

## 6. Login to AWS

Run:

```bash
aws sso login --profile cml-lab
```

A browser window will open for authentication.

Verify the account:

```bash
aws sts get-caller-identity --profile cml-lab
```

Make sure the returned AWS account is the correct account.

## 7. Set the AWS Profile

**Git Bash / Linux / macOS**

```bash
export AWS_PROFILE=cml-lab
```

**PowerShell**

```powershell
$env:AWS_PROFILE="cml-lab"
```

Verify:

```bash
aws sts get-caller-identity
```

Terraform will use this AWS profile automatically.

## 8. Clone the Repository

Replace `<YOUR_REPOSITORY_URL>` with the actual repository URL.

```bash
git clone <YOUR_REPOSITORY_URL>
```

Example:

```bash
git clone https://github.com/YOUR_USERNAME/cml-aws-lab.git
```

Enter the repository:

```bash
cd cml-aws-lab
```

Check:

```bash
git status
```

## 9. Configure Terraform

Enter the Terraform directory:

```bash
cd infrastructure
```

Copy the example configuration.

**Git Bash / Linux / macOS**

```bash
cp terraform.tfvars.example terraform.tfvars
```

**PowerShell**

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Open:

```bash
terraform.tfvars
```

Configure the values.

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

ssh_public_key = "ssh-ed25519 AAAA... user@computer"

monthly_budget_usd = 80
budget_email       = "YOUR_EMAIL@example.com"
```

## 10. Configure Your Public IP

The AWS Security Group only allows SSH and HTTPS access from the configured management IP.

Find your public IP:

```bash
curl https://checkip.amazonaws.com
```

Example:

```text
203.0.113.25
```

Set:

```hcl
allowed_management_cidr = "203.0.113.25/32"
```

The `/32` means only that single IPv4 address is allowed.

If your public IP changes later, update `terraform.tfvars` and run:

```bash
terraform apply
```

## 11. Configure SSH

If you do not already have an SSH key, create one:

```bash
ssh-keygen -t ed25519 -C "cml-aws-lab"
```

This normally creates:

```text
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
```

Put the contents of the public key into:

```hcl
ssh_public_key = "ssh-ed25519 AAAA... user@computer"
```

> Important: Only the public key goes into `terraform.tfvars`.
>
> Never commit or upload:
>
> - `id_ed25519`
>
> The private key must remain on your computer.

## 12. AWS Budget

Terraform creates an AWS monthly budget.

Default:

```text
$80 USD / month
```

Alerts:

- 50% actual     → $40
- 80% actual     → $64
- 100% forecast  → $80 forecast
- 100% actual    → $80 actual

The budget is an alert, not a hard spending limit.

AWS resources can continue running after a budget threshold is reached.

The CML EC2 instance should be stopped when it is not being used.

Stopping the EC2 instance stops normal EC2 compute charges, but EBS storage and other AWS resources can still incur charges.

## 13. Run Terraform Checks

Return to the repository root:

```bash
cd ..
```

Make the script executable:

```bash
chmod +x run-terraform.sh
```

Run:

```bash
./run-terraform.sh
```

The script runs:

- `terraform init`
- `terraform fmt`
- `terraform validate`
- `terraform plan`
- `terraform output`

It does not run `terraform apply`.

## 14. Review the Terraform Plan

Review:

```bash
terraform plan
```

Expected resources include:

- AWS Budget
- VPC
- Internet Gateway
- Public Subnet
- Route Table
- Route Table Association
- Security Group
- Security Group Rules
- SSH Key Pair
- EC2 Instance

If the plan contains unexpected resources, stop and review before continuing.

## 15. Create the AWS Infrastructure

Enter the Terraform directory:

```bash
cd infrastructure
```

Run:

```bash
terraform apply
```

Terraform will show the plan again.

Review it and enter:

```text
yes
```

Terraform will create the AWS infrastructure.

## 16. Get the VM Information

After deployment:

```bash
terraform output
```

You should see information such as:

- `cml_instance_id`
- `cml_instance_type`
- `cml_private_ip`
- `cml_public_ip`
- `cml_ssh_command`

Example:

```text
cml_instance_type = "c8i.8xlarge"
cml_public_ip     = "x.x.x.x"
cml_ssh_command   = "ssh ubuntu@x.x.x.x"
```

## 17. Connect to the VM

Use the SSH command from Terraform:

```bash
ssh ubuntu@<PUBLIC_IP>
```

Example:

```bash
ssh ubuntu@203.0.113.25
```

## 18. Install Cisco Modeling Labs

Terraform only creates the AWS infrastructure.

CML is installed separately.

Use Cisco's official documentation for the CML version being installed.

- CML Installation Guide: https://developer.cisco.com/docs/modeling-labs/cml-installation-guide/
- CML Quick Start: https://developer.cisco.com/docs/modeling-labs/cml-quick-start-guide/
- CML Downloads: https://developer.cisco.com/docs/modeling-labs/downloading-files-for-cml-installation/

Use the CML version and installation method appropriate for your Cisco license.

The AWS instance created by this Terraform project has nested virtualization enabled for running the CML virtual network nodes.

## 19. Access CML

After CML has been installed and configured, open:

```text
https://<PUBLIC_IP>
```

Example:

```text
https://203.0.113.25
```

If the page cannot be reached, check:

- EC2 is running.
- CML is running.
- TCP/443 is allowed in the Security Group.
- Your current public IP matches `allowed_management_cidr`.
- You are using the current EC2 public IP.

## 20. Stop the VM When Finished

There is intentionally no automatic start/stop schedule.

When finished studying, stop the EC2 instance.

**AWS Console**

Go to:

- EC2
- Instances
- Select CML instance
- Instance state
- Stop instance

**AWS CLI**

```bash
aws ec2 stop-instances --instance-ids <INSTANCE_ID>
```

Start it again when needed:

```bash
aws ec2 start-instances --instance-ids <INSTANCE_ID>
```

## 21. Public IP After Stop/Start

This project does not use an Elastic IP.

Therefore, the public IP may change after stopping and starting the instance.

Check the current IP:

```bash
aws ec2 describe-instances \
  --instance-ids <INSTANCE_ID> \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text
```

Use the new IP when accessing CML or SSH.

If your own public IP changes, also update:

```hcl
allowed_management_cidr = "YOUR.NEW.PUBLIC.IP/32"
```

and run:

```bash
terraform apply
```

## 22. Destroy the Infrastructure

If the lab is no longer required:

```bash
cd infrastructure
terraform destroy
```

Review the resources that will be removed.

Enter:

```text
yes
```

> WARNING: `terraform destroy` removes the AWS resources managed by this Terraform project.
>
> Do not run this command if you need to keep the CML VM or its data.

## 23. Security

Never commit the following files or information:

- AWS credentials
- AWS access keys
- AWS secret keys
- AWS session tokens
- SSH private keys
- `terraform.tfvars`
- `terraform.tfstate`
- Cisco software packages
''', encoding='utf-8')"