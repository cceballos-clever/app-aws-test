packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

source "amazon-ebs" "example" {
  region           = "us-east-1"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  instance_type   = "t3.micro"
  subnet_id       = "vpc-0ad410d5d4e52c552"
  ssh_username    = "ubuntu"
  ami_name        = "packer-test-aws-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.example"]

  post-processor "manifest" {
    output = "manifest.json"
  }
}
