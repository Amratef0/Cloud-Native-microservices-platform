terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

# أحدث نسخة Ubuntu 24.04 (AWS بتجيبها لوحدها)
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# المفتاح العام اللي عملناه
resource "aws_key_pair" "rowad" {
  key_name   = "rowad-key"
  public_key = file("C:/Users/lenovo/.ssh/rowad-key.pub")
}

# الـ Firewall: مين يقدر يدخل على السيرفر
resource "aws_security_group" "rowad" {
  name        = "rowad-sg"
  description = "Rowad project"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# السيرفر نفسه
resource "aws_instance" "rowad" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = "t3.small"
  key_name               = aws_key_pair.rowad.key_name
  vpc_security_group_ids = [aws_security_group.rowad.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "rowad-server"
  }
}

# يطبعلنا عنوان السيرفر بعد ما يتعمل
output "server_ip" {
  value = aws_instance.rowad.public_ip
}