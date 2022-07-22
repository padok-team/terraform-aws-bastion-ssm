resource "aws_autoscaling_group" "bastion" {
  name_prefix = local.lname

  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  # grace periode before checking the instance availability
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type

  # patch management
  max_instance_lifetime = var.max_instance_lifetime

  # network (subnet for asg / instances)
  # used instead of availability_zones
  vpc_zone_identifier = var.vpc_zone_identifier

  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }

  # cloud watch metrics
  enabled_metrics = var.enabled_metrics

  dynamic "tag" {
    for_each = local.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "Name"
    value               = trim(local.lname, "-")
    propagate_at_launch = true
  }

  tag {
    key                 = "SSMAutoUpdate"
    value               = "true"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
  
  provisioner "local-exec" {
    command = "aws ec2 describe-instances --filters \"Name=tag:Name,Values=bastion-ssm-*\" --query \"Reservations[*].Instances[*].[InstanceId]\" --output text"
  }
}
