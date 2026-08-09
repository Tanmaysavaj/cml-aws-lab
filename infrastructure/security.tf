resource "aws_security_group" "cml" {
  name        = "${var.project_name}-sg"
  description = "Security group for Cisco Modeling Labs"
  vpc_id      = aws_vpc.cml.id

  tags = {
    Name = "${var.project_name}-sg"
  }
}


resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.cml.id

  description = "CML HTTPS access"

  cidr_ipv4   = var.allowed_management_cidr
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}


resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.cml.id

  description = "SSH management access"

  cidr_ipv4   = var.allowed_management_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.cml.id

  description = "Allow outbound Internet access"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}