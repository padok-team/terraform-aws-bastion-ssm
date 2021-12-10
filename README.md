# AWS SSM Bastion Terraform module

Terraform module which creates a SSM Bastion resources on AWS. This module will allow you to use SSH tunnel to access your private ressources (like EKS endpoint, RDS, etc).

Currently SSM start-session doesn't support remote forwarding. To tackle this issue, we use a bastion host ([there is an open issue to add this feature to SSM](https://github.com/aws/amazon-ssm-agent/pull/389)). When the remote forward will be available, this module will be updated because we won't need an host (and SSH key, btw).

To easily use remote forwarding, add the following configuration to your SSH config (`~/.ssh/config`):

```
host i-* mi-*
  ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
  User ssm-user
```

To open a SSH tunnel, you can use the following command:

```
ssh -i ~/.ssh/id_rsa -L 8080:localhost:8080 i-xxxxxxxxxxx
```

You can get an overview of why SSM is a very good feature by reading our blog post about it [here](https://www.padok.fr/en/blog/aws-ssh-bastion).

### Note about Patch Management - Instance lifetime

By default, EC2 instance will be patched with the latest patches during first launch. We also configure the autoscaling group to recreate bastion instance at least once a week (by default, you can configure the delay). Read more about Instance lifetime [here](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-max-instance-lifetime.html).

## User Stories for this module

- AAOps I can deploy a SSM Bastion thats allow me to access my private endpoint (EKS, RDS, etc)

## Usage

```hcl

module "my_ssm_bastion" {
  source = ""

  ssm_logging_bucket_name = aws_s3_bucket.ssm_logs.id
  security_groups         = [aws_security_group.bastion_ssm.id]
  vpc_zone_identifier     = module.my_vpc.private_subnets_ids
}

output "ssm_key" {
  value     = module.my_ssm_bastion.ssm_private_key
  sensitive = true
}

```

## Examples

- [Basic usage](examples/basic/main.tf)
<!-- BEGIN_TF_DOCS -->

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of security group IDs to associate. | `list(string)` | n/a | yes |
| <a name="input_ssm_logging_bucket_name"></a> [ssm\_logging\_bucket\_name](#input\_ssm\_logging\_bucket\_name) | SSM Logging Bucket name | `string` | n/a | yes |
| <a name="input_vpc_zone_identifier"></a> [vpc\_zone\_identifier](#input\_vpc\_zone\_identifier) | A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. | `list(any)` | n/a | yes |
| <a name="input_add_ssm_user_from_sudoers"></a> [add\_ssm\_user\_from\_sudoers](#input\_add\_ssm\_user\_from\_sudoers) | Wether you want to add the ssm\_user to sudoers | `bool` | `false` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The AMI from which to launch the instance | `string` | `""` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Associate a public ip address with the network interface | `bool` | `false` | no |
| <a name="input_custom_iam"></a> [custom\_iam](#input\_custom\_iam) | A list of data.aws\_iam\_policy\_document | `list(string)` | `[]` | no |
| <a name="input_custom_ssm_user_public_key"></a> [custom\_ssm\_user\_public\_key](#input\_custom\_ssm\_user\_public\_key) | The public key to use for the ssm-user user | `string` | `""` | no |
| <a name="input_delete_on_termination"></a> [delete\_on\_termination](#input\_delete\_on\_termination) | Whether the network interface should be destroyed on instance termination | `bool` | `true` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group | `number` | `1` | no |
| <a name="input_device_name"></a> [device\_name](#input\_device\_name) | Name of the device (/dev/xxxx) | `string` | `"/dev/xvda"` | no |
| <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics) | A list of metrics to collect | `list(any)` | <pre>[<br>  "GroupMinSize",<br>  "GroupMaxSize",<br>  "GroupDesiredCapacity",<br>  "GroupInServiceInstances",<br>  "GroupPendingInstances",<br>  "GroupStandbyInstances",<br>  "GroupTerminatingInstances",<br>  "GroupTotalInstances"<br>]</pre> | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | Encrypt of not the volume | `bool` | `true` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Time (in seconds) after instance comes into service before checking health | `number` | `300` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | Controls how health checking is done | `string` | `"EC2"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use for the bastion | `string` | `"t3.medium"` | no |
| <a name="input_manage_ssm_user_ssh_key"></a> [manage\_ssm\_user\_ssh\_key](#input\_manage\_ssm\_user\_ssh\_key) | Wether you want to let the module manage the ssh key for the ssm-user, if set to false you need to set `custom_ssm_user_public_key` | `bool` | `true` | no |
| <a name="input_max_instance_lifetime"></a> [max\_instance\_lifetime](#input\_max\_instance\_lifetime) | The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds | `number` | `null` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum size of the Auto Scaling Group | `number` | `1` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum size of the Auto Scaling Group | `number` | `1` | no |
| <a name="input_update_default_version"></a> [update\_default\_version](#input\_update\_default\_version) | Whether to update Default Version each update. | `bool` | `true` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | Size of EBS volume | `number` | `10` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | Type of EBS volume | `string` | `"gp3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssm_private_key"></a> [ssm\_private\_key](#output\_ssm\_private\_key) | ssm ssh private key for tunnel |
<!-- END_TF_DOCS -->
