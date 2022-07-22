# default IAM for our Bastion
# merged with config provided to init the module
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "bastion" {
  # a permission needed by SSM to validate
  # that the bucket has encryption enabled
  # otherwise we can't use it to store the log
  statement {
    sid = "SSMLoggingEnc"

    effect = "Allow"

    actions = [
      "s3:GetEncryptionConfiguration"
    ]

    resources = ["arn:aws:s3:::${local.ssm_logging_bucket_name}"]
  }
  # needed by SSM to store session logs
  statement {
    sid = "SSMLogging"

    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = ["arn:aws:s3:::${local.ssm_logging_bucket_name}/*"]
  }
}

resource "aws_iam_role" "bastion" {
  name               = "${local.lname}_asg_iam"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "bastion" {
  name   = "${local.lname}_asg"
  role   = aws_iam_role.bastion.id
  policy = data.aws_iam_policy_document.bastion.json
}

# enforce SSM usage
# This policy is mandatory to permit SSM to work
resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion.id
}

# custom roles added at module call
# passed as a list of data.aws_iam_policy_document
resource "aws_iam_role_policy" "custom_iam" {
  for_each = length(var.custom_iam) > 0 ? toset(var.custom_iam) : []

  name   = "${local.lname}_custom_iam_${index(var.custom_iam, each.key)}"
  role   = aws_iam_role.bastion.id
  policy = each.key
}

# finaly, create the instance profile from iam role
resource "aws_iam_instance_profile" "bastion" {
  name_prefix = "${local.lname}_asg_iam"
  role        = aws_iam_role.bastion.name
}
