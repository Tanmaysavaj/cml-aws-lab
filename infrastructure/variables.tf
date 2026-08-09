variable "aws_region" {
  description = "AWS region where the CML lab will be deployed"
  type        = string
  default     = "ca-central-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "cml-aws-lab"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

variable "vpc_cidr" {
  description = "CIDR block for the CML VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type used for CML"
  type        = string
  default     = "c8i.8xlarge"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 200
}

variable "allowed_management_cidr" {
  description = "Public IPv4 CIDR allowed to access CML management and SSH"
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_management_cidr, 0))
    error_message = "allowed_management_cidr must be a valid IPv4 CIDR, for example 203.0.113.10/32."
  }
}
variable "monthly_budget_usd" {
  description = "Monthly AWS cost budget in USD"
  type        = number
  default     = 80

  validation {
    condition     = var.monthly_budget_usd >= 80
    error_message = "monthly_budget_usd must be at least 80 USD."
  }
}

variable "budget_email" {
  description = "Email address that receives AWS budget alerts"
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.budget_email))
    error_message = "budget_email must be a valid email address."
  }
}
variable "ssh_public_key" {
  description = "SSH public key used to access the CML host"
  type        = string

  validation {
    condition     = length(trimspace(var.ssh_public_key)) > 0
    error_message = "ssh_public_key must not be empty."
  }
}