terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.25.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.1.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "vocareum"
}

provider "cloudinit" {

}

data "template_cloudinit_config" "config-vpn" {
  gzip          = true
  base64_encode = true

  part {
    filename     = var.variables
    content_type = "text/x-shellscript"
    content      = file(var.variables)
  }

  part {
    filename     = var.packages
    content_type = "text/x-shellscript"
    content      = file(var.packages)
  }

  part {
    filename     = var.certificates
    content_type = "text/x-shellscript"
    content      = file(var.certificates)
  }

  part {
    filename     = var.cloud-config-vpn
    content_type = "text/x-shellscript"
    content      = file(var.cloud-config-vpn)
  }

}
