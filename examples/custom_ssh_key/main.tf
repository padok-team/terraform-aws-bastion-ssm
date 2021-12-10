terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.63"
    }
  }
}

provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Env         = local.env
      Region      = local.region
      OwnedBy     = "Padok"
      ManagedByTF = true
    }
  }
}

# some variables to make life easier
locals {

  name   = "basic_private"
  env    = "test"
  region = "eu-west-3"
}

################################################################################
# Bastion
################################################################################

module "my_ssm_bastion" {
  source = "../.."

  ssm_logging_bucket_name = aws_s3_bucket.ssm_logs.id
  security_groups         = [aws_security_group.bastion_ssm.id]
  vpc_zone_identifier     = module.my_vpc.private_subnets_ids

  manage_ssm_user_ssh_key = false
  custom_ssm_user_public_key = tls_private_key.ssm_user.public_key_openssh

  add_ssm_user_from_sudoers = true
}

resource "tls_private_key" "ssm_user" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

output "ssm_key" {
  value     = tls_private_key.ssm_user.private_key_pem
  sensitive = true
}

################################################################################
# Supporting resources
################################################################################

module "my_vpc" {
  source = "git@github.com:padok-team/terraform-aws-network.git"

  vpc_name              = local.name
  vpc_availability_zone = ["eu-west-3a", "eu-west-3b"]

  vpc_cidr            = "10.143.0.0/16"
  public_subnet_cidr  = ["10.143.1.0/28", "10.143.2.0/28"]    # small subnets for natgateway
  private_subnet_cidr = ["10.143.64.0/18", "10.143.128.0/18"] # big subnet for EKS

  single_nat_gateway = true # warning : not for production !

  tags = {
    CostCenter = "Network"
  }
}

# s3 bucket for logging
resource "aws_s3_bucket" "ssm_logs" {
  bucket = "bastion-ssm-logs"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}

# create a security group
resource "aws_security_group" "bastion_ssm" {
  name        = "bastion_ssm"
  description = "Allow output for bastion"
  vpc_id      = module.my_vpc.vpc_id

  # external access
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # tunnel to RDS
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
