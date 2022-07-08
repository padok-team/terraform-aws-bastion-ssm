resource "aws_ssm_association" "aws_ssm_auto_update" {
  name = "AWS-UpdateSSMAgent"

  schedule_expression = "cron(0 2 ? * SUN *)"

  targets {
    key    = "tag:SSMAutoUpdate"
    values = ["true"]
  }
}
