# Plugin requerido
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

# Variables
variable "key_name" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "security_group_id" {
  type = string
}

# Source
source "amazon-ebs" "example" {
  region                 = var.region
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  ssh_username           = "ubuntu"
  ssh_keypair_name       = var.key_name
  ssh_private_key_file   = var.private_key_path
  ami_name               = "packer-test-aws-{{timestamp}}"

  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  instance_type              = "t3.micro"
  associate_public_ip_address = true
  ssh_interface               = "public_ip"
  ssh_timeout                 = "10m"
}

# Provisioner: usa Ansible desde el runner
build {
  sources = ["source.amazon-ebs.example"]

  provisioner "ansible" {
    playbook_file    = "../ansible/playbook.yml" # playbook dentro del repo
    user             = "ubuntu"
    private_key_file = var.private_key_path
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}
