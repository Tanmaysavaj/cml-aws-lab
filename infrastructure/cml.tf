data "aws_ssm_parameter" "ubuntu_2404_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}


resource "aws_key_pair" "cml" {
  key_name   = "${var.project_name}-ssh-key"
  public_key = var.ssh_public_key

  tags = {
    Name = "${var.project_name}-ssh-key"
  }
}


resource "aws_instance" "cml" {
  ami           = data.aws_ssm_parameter.ubuntu_2404_ami.value
  instance_type = var.instance_type

  subnet_id = aws_subnet.public.id

  vpc_security_group_ids = [
    aws_security_group.cml.id
  ]

  key_name = aws_key_pair.cml.key_name

  associate_public_ip_address = true

  cpu_options {
    nested_virtualization = "enabled"
  }

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${var.project_name}-cml"
  }
}