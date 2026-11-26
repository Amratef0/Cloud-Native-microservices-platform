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
  public_key = file(pathexpand(var.ssh_public_key_path))
}

# الـ Firewall: مين يقدر يدخل على السيرفر
resource "aws_security_group" "rowad" {
  name        = "rowad-sg"
  description = "Rowad project"

  ingress {
    description = "SSH (team only)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }

  ingress {
    description = "HTTP (public website)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubernetes API (team only)"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
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

# يكتب ملف inventory.ini لوحده بالـ IP الجديد
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/inventory.ini"
  content = replace(
    templatefile("${path.module}/ansible/inventory.tftpl", {
      server_ip = aws_instance.rowad.public_ip
    }),
    "\r", ""
  )
}

# ---------- S3 bucket ----------
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "rowad" {
  # اسم الـ bucket لازم يكون فريد في كل AWS، فبنضيف رقم الحساب
  bucket        = "rowad-project-${data.aws_caller_identity.current.account_id}"
  force_destroy = true # يسمح لـ terraform destroy بمسح الـ bucket حتى لو فيه ملفات

  tags = {
    Name = "rowad-bucket"
  }
}

# يمنع أي وصول عام للملفات
resource "aws_s3_bucket_public_access_block" "rowad" {
  bucket                  = aws_s3_bucket.rowad.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# يحتفظ بنسخ قديمة من الملفات لو اتعدلت
resource "aws_s3_bucket_versioning" "rowad" {
  bucket = aws_s3_bucket.rowad.id
  versioning_configuration {
    status = "Enabled"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.rowad.bucket
}