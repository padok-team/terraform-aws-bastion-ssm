# AWS SSM Bastion Terraform module

Terraform module which creates a SSM Bastion resources on AWS. This module will allow you to connect to private ressources in your VPC (like EKS endpoint, RDS, etc).

### Context

To open a tunnel (local or remote), read the following documentation: https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-sessions-start.html#sessions-remote-port-forwarding

#### TL;DR

Local Forward :
```bash
aws ssm start-session \
    --target instance-id \
    --document-name AWS-StartPortForwardingSession \
    --parameters '{"portNumber":["80"], "localPortNumber":["56789"]}'
```

Remote Forward to an RDS instance :
```bash
aws ssm start-session \
    --target instance-id \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters '{"host":["mydb.example.us-east-2.rds.amazonaws.com"],"portNumber":["3306"], "localPortNumber":["3306"]}'
```

Remote Forward to a private EKS API Server :
```bash
aws ssm start-session \
    --target instance-id \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters '{"host":["https://216E6F4D2AD7F5E4E689AA120CD23E26.gr7.eu-west-3.eks.amazonaws.com"],"portNumber":["10443"], "localPortNumber":["443"]}'
```

### Note about Patch Management - Instance lifetime

By default, EC2 instances will be patched with the latest patches during first launch. We also configured the autoscaling group to recreate the bastion instance at least once a week (by default, you can configure the frequency). You can learn more about Instance lifetime [here](https://docs.aws.amazon.com/autoscaling/ec2/userguide/asg-max-instance-lifetime.html).

## User Stories for this module

- AAOps I can deploy a SSM Bastion that allows me to access my private endpoints (EKS, RDS, etc)

## Usage

```hcl
module "my_ssm_bastion" {
  source = "https://github.com/padok-team/terraform-aws-bastion-ssm"

  ssm_logging_bucket_name = aws_s3_bucket.ssm_logs.id
  security_groups         = [aws_security_group.bastion_ssm.id]
  vpc_zone_identifier     = module.my_vpc.private_subnets_ids
}
```

## Examples

- [AAOps I can deploy a SSM Bastion that allows me to access my private endpoints](examples/basic/main.tf)
<!-- BEGIN_TF_DOCS -->
## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of security group IDs to associate. | `list(string)` | n/a | yes |
| <a name="input_ssm_logging_bucket_name"></a> [ssm\_logging\_bucket\_name](#input\_ssm\_logging\_bucket\_name) | SSM Logging Bucket name | `string` | n/a | yes |
| <a name="input_vpc_zone_identifier"></a> [vpc\_zone\_identifier](#input\_vpc\_zone\_identifier) | A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. | `list(any)` | n/a | yes |
| <a name="input_add_ssm_user_to_sudoers"></a> [add\_ssm\_user\_to\_sudoers](#input\_add\_ssm\_user\_to\_sudoers) | Set to true if you want to add the ssm\_user to sudoers | `bool` | `false` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | The AMI from which to launch the instance | `string` | `""` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Associate a public ip address with the network interface | `bool` | `false` | no |
| <a name="input_custom_iam"></a> [custom\_iam](#input\_custom\_iam) | A list of iam policy documents to give extra permissions to the Bastion instance | `list(string)` | `[]` | no |
| <a name="input_custom_ssm_user_public_key"></a> [custom\_ssm\_user\_public\_key](#input\_custom\_ssm\_user\_public\_key) | The public key to use for the ssm-user user | `string` | `""` | no |
| <a name="input_delete_on_termination"></a> [delete\_on\_termination](#input\_delete\_on\_termination) | Whether the network interface should be destroyed on instance termination | `bool` | `true` | no |
| <a name="input_desired_capacity"></a> [desired\_capacity](#input\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the group | `number` | `1` | no |
| <a name="input_device_name"></a> [device\_name](#input\_device\_name) | Name of the device (/dev/xxxx) to mount | `string` | `"/dev/xvda"` | no |
| <a name="input_enabled_metrics"></a> [enabled\_metrics](#input\_enabled\_metrics) | A list of metrics to collect in cloudwatch | `list(any)` | <pre>[<br>  "GroupMinSize",<br>  "GroupMaxSize",<br>  "GroupDesiredCapacity",<br>  "GroupInServiceInstances",<br>  "GroupPendingInstances",<br>  "GroupStandbyInstances",<br>  "GroupTerminatingInstances",<br>  "GroupTotalInstances"<br>]</pre> | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | Set to true to encrypt the EBS volume | `bool` | `true` | no |
| <a name="input_health_check_grace_period"></a> [health\_check\_grace\_period](#input\_health\_check\_grace\_period) | Time (in seconds) after instance comes into service before checking health | `number` | `300` | no |
| <a name="input_health_check_type"></a> [health\_check\_type](#input\_health\_check\_type) | Controls how health checking is done | `string` | `"EC2"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use for the bastion | `string` | `"t3.medium"` | no |
| <a name="input_manage_ssm_user_ssh_key"></a> [manage\_ssm\_user\_ssh\_key](#input\_manage\_ssm\_user\_ssh\_key) | Set to true if you want to let the module manage the ssh key for the ssm-user, if set to false you need to set `custom_ssm_user_public_key` | `bool` | `true` | no |
| <a name="input_max_instance_lifetime"></a> [max\_instance\_lifetime](#input\_max\_instance\_lifetime) | The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds | `number` | `null` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | The maximum size of the Auto Scaling Group | `number` | `1` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | The minimum size of the Auto Scaling Group | `number` | `1` | no |
| <a name="input_ssm_logging_bucket_encryption"></a> [ssm\_logging\_bucket\_encryption](#input\_ssm\_logging\_bucket\_encryption) | Set to true if the Amazon S3 bucket you specified in the s3BucketName input must be encrypted | `bool` | `true` | no |
| <a name="input_update_default_version"></a> [update\_default\_version](#input\_update\_default\_version) | Whether to update Default Version each update. | `bool` | `true` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | Size of the EBS volume | `number` | `10` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | Type of EBS volume | `string` | `"gp3"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssm_private_key"></a> [ssm\_private\_key](#output\_ssm\_private\_key) | ssm ssh private key for tunnel |
<!-- END_TF_DOCS -->

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

```text
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

  https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
```
