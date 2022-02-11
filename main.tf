locals {
  # prefix
  lname = "bastion-ssm-${random_pet.version.id}-"

  tags = {
    Name = trim(local.lname, "-")
  }
}

# get account id
data "aws_caller_identity" "current" {}

# current region
data "aws_region" "current" {}

# a random name used to name our resources
# use easily redeploy with a tf taint
resource "random_pet" "version" {}

# default AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
