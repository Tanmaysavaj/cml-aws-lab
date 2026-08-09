output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}

output "availability_zones" {
  description = "Available availability zones"
  value       = data.aws_availability_zones.available.names
}

output "monthly_budget" {
  description = "Configured monthly AWS budget in USD"
  value       = aws_budgets_budget.monthly.limit_amount
}

output "budget_email" {
  description = "Email address configured for budget alerts"
  value       = var.budget_email
}
output "vpc_id" {
  description = "ID of the CML VPC"
  value       = aws_vpc.cml.id
}

output "vpc_cidr" {
  description = "CIDR block of the CML VPC"
  value       = aws_vpc.cml.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "public_subnet_cidr" {
  description = "CIDR block of the public subnet"
  value       = aws_subnet.public.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.cml.id
}
output "security_group_id" {
  description = "Security group ID for the CML instance"
  value       = aws_security_group.cml.id
}