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