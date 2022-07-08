#
# Variables for SSM
#
variable "ssm_logging_bucket_name" {
  description = "SSM Logging Bucket name"
  type        = string
}

variable "ssm_logging_bucket_encryption" {
  description = "Set to true if the Amazon S3 bucket you specified in the s3BucketName input must be encrypted"
  type        = bool
  default     = true
}

#
# Variables for IAM
#
variable "custom_iam" {
  description = "A list of iam policy documents to give extra permissions to the Bastion instance"
  type        = list(string)
  default     = []
}

#
# Variables for launch_template
#
variable "ami_id" {
  description = "The AMI from which to launch the instance"
  type        = string
  default     = ""
}

variable "update_default_version" {
  description = "Whether to update Default Version each update."
  type        = bool
  default     = true
}

#
# Network
#
variable "associate_public_ip_address" {
  description = "Associate a public ip address with the network interface"
  type        = bool
  default     = false
}

variable "delete_on_termination" {
  description = "Whether the network interface should be destroyed on instance termination"
  type        = bool
  default     = true
}

variable "security_groups" {
  description = "A list of security group IDs to associate."
  type        = list(string)
}

variable "device_name" {
  description = "Name of the device (/dev/xxxx) to mount"
  type        = string
  default     = "/dev/xvda"
}

variable "volume_size" {
  description = "Size of the EBS volume"
  type        = number
  default     = 10
}

variable "volume_type" {
  description = "Type of EBS volume"
  type        = string
  default     = "gp3"
}

variable "encrypted" {
  description = "Set to true to encrypt the EBS volume"
  type        = bool
  default     = true
}

#
# AutoScaling Groups
#
variable "max_size" {
  description = "The maximum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "The minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  type        = number
  default     = 1
}

variable "health_check_grace_period" {
  description = "Time (in seconds) after instance comes into service before checking health"
  type        = number
  default     = 300
}

variable "health_check_type" {
  description = "Controls how health checking is done"
  type        = string
  default     = "EC2"
}

variable "max_instance_lifetime" {
  description = "The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 604800 and 31536000 seconds"
  type        = number
  default     = null
}

variable "vpc_zone_identifier" {
  description = "A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside."
  type        = list(any)
}

variable "instance_type" {
  description = "Instance type to use for the bastion"
  type        = string
  default     = "t3.medium"
}

variable "enabled_metrics" {
  description = "A list of metrics to collect in cloudwatch"
  type        = list(any)
  default = [
    "GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity",
    "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances",
    "GroupTerminatingInstances", "GroupTotalInstances"
  ]
}

variable "add_ssm_user_to_sudoers" {
  description = "Set to true if you want to add the ssm_user to sudoers"
  type        = bool
  default     = false
}
