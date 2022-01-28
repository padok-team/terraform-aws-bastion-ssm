
# Minimal launch template for SSH setup
locals {
  bastion_userdata = <<EOF
#cloud-config
package_update: true
package_upgrade: true
users:
  - name: ssm-user
    gecos: SSM USER
    ssh_authorized_keys:
      - ${var.manage_ssm_user_ssh_key ? chomp(tls_private_key.ssm_user[0].public_key_openssh) : var.custom_ssm_user_public_key}
runcmd:
  - echo "MaxAuthTries 20" >> /etc/ssh/sshd_config
  - systemctl restart sshd
${var.add_ssm_user_to_sudoers ? "  - echo 'ssm-user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/ssm-user" : ""}
EOF
}

# an SSH key for tunnels
# shared for all ops while isn't possible to open remote tunnels from AWS SSM
# THIS WILL BE REMOVE WHEN SSM REMOTE TUNNEL WILL BE IMPLEMENTED
resource "tls_private_key" "ssm_user" {
  count = var.manage_ssm_user_ssh_key ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = "4096"
}

# an SSH key for ec2-user
# needed to debug bastion and access root account
#resource "tls_private_key" "ec2_user" {
#  count = var.manage_ec2_user_ssh_key ? 1 : 0
#
#  algorithm = "RSA"
#  rsa_bits  = "4096"
#}
#resource "aws_key_pair" "ec2_user" {
#  key_name   = "bastion_ssm_ec2_user_2"
#  public_key = var.manage_ec2_user_ssh_key ? tls_private_key.ec2_user[0].public_key_openssh : var.custom_ec2_user_public_key
#}

resource "aws_launch_template" "bastion" {
  name_prefix = local.lname
  image_id    = var.ami_id == "" ? data.aws_ami.amazon-linux-2.image_id : var.ami_id

  instance_type = var.instance_type

  # ec2-user key doesn't for now
  # we will fix this later with the new SSM remote tunnel
  #key_name  = aws_key_pair.ec2_user.key_name

  user_data = base64encode(local.bastion_userdata)

  # very important: update to the latest version for
  # each update. Otherwise it will stick to version 1
  update_default_version = var.update_default_version

  # disk setting
  block_device_mappings {
    device_name = var.device_name
    ebs {
      volume_size = var.volume_size
      volume_type = var.volume_type
      encrypted   = var.encrypted
    }
  }

  # network setting
  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    delete_on_termination       = var.delete_on_termination
    security_groups             = var.security_groups
    description                 = trimsuffix(local.lname, "-")
  }

  # iam profile for instances
  iam_instance_profile {
    arn = aws_iam_instance_profile.profile.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}
