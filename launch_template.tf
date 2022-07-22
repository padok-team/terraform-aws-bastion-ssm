# Minimal launch template for SSH setup
locals {
  bastion_userdata = <<EOF
#cloud-config
package_update: true
package_upgrade: true
${var.add_ssm_user_to_sudoers ? "  runcmd: [ 'echo \"ssm-user ALL=(ALL) NOPASSWD:ALL\">> /etc/sudoers.d/ssm-user' ]" : ""}
EOF
}

resource "aws_launch_template" "bastion" {
  name_prefix = local.lname
  image_id    = var.ami_id == "" ? data.aws_ami.amazon_linux_2.image_id : var.ami_id

  instance_type = var.instance_type

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
    security_groups             = [aws_security_group.ssm_sg.id]
    description                 = trimsuffix(local.lname, "-")
  }

  # iam profile for instances
  iam_instance_profile {
    arn = aws_iam_instance_profile.bastion.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}
