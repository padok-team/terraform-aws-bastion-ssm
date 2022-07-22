data "aws_subnet" "first" {
  id = var.vpc_zone_identifier[0]
}

resource "aws_security_group" "ssm_sg" {
  name        = "bastion-ssm-${random_pet.version.id}"
  description = "Security group for bastion-ssm-${random_pet.version.id}"
  vpc_id      = data.aws_subnet.first.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
