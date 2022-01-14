# enable logging to s3 for session manager

# if you encounterd this error:
#
# Error: Error creating SSM document: DocumentAlreadyExists: Document with same name SSM-SessionManagerRunShell already exists
#
# delete the document first:
# $ aws --profile $AWS_PROFILE ssm delete-document --name  SSM-SessionManagerRunShell
#
# Source: https://github.com/hashicorp/terraform-provider-aws/issues/7516

resource "aws_ssm_document" "ssm_logging" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = <<EOF
{
    "schemaVersion": "1.0",
    "description": "Document to hold regional settings for Session Manager",
    "sessionType": "Standard_Stream",
    "inputs": {
        "s3BucketName": "${var.ssm_logging_bucket_name}",
        "s3KeyPrefix": "",
        "s3EncryptionEnabled": ${var.ssm_logging_bucket_encryption},
        "shellProfile": {
            "linux" : "/bin/bash",
            "windows" : ""
        }
    }
}
EOF
}
