//https://github.com/aws-samples/amazon-cloudwatch-log-centralizer/blob/master/cfn/centralLogging.yml
variable "audit_account_id" {
}

locals {
  audit_assume_role = "arn:aws:iam::${var.audit_account_id}:role/OrganizationAccountAccessRole"
}

provider "aws" {
  alias = "audit"
  assume_role {
    role_arn = local.audit_assume_role
  }
}

data "aws_caller_identity" "audit_account" {
  provider = aws.audit
}

data "aws_iam_policy_document" "CWLtoFirehoseRole_policy_document" {
  provider = aws.audit
  version  = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
    "sts:AssumeRole"]
    principals {
      identifiers = [
        "logs.eu-north-1.amazonaws.com",
        "logs.ap-south-1.amazonaws.com",
        "logs.eu-west-3.amazonaws.com",
        "logs.eu-west-2.amazonaws.com",
        "logs.eu-west-1.amazonaws.com",
        "logs.ap-northeast-3.amazonaws.com",
        "logs.ap-northeast-2.amazonaws.com",
        "logs.ap-northeast-1.amazonaws.com",
        "logs.sa-east-1.amazonaws.com",
        "logs.ca-central-1.amazonaws.com",
        "logs.ap-southeast-1.amazonaws.com",
        "logs.ap-southeast-2.amazonaws.com",
        "logs.eu-central-1.amazonaws.com",
        "logs.us-east-1.amazonaws.com",
        "logs.us-east-2.amazonaws.com",
        "logs.us-west-1.amazonaws.com",
        "logs.us-west-2.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "CWLtoFirehoseRole" {
  provider           = aws.audit
  name               = "CWLtoFirehoseRole"
  assume_role_policy = data.aws_iam_policy_document.CWLtoFirehoseRole_policy_document.json
}

data "aws_iam_policy_document" "CWLtoFirehosePolicy_policy_document" {
  provider = aws.audit
  version  = "2012-10-17"
  statement {
    effect    = "Allow"
    actions   = ["firehose:PutRecord"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "CWLtoFirehosePolicy" {
  provider = aws.audit
  name     = "CWL_to_Kinesis_Policy"
  policy   = data.aws_iam_policy_document.CWLtoFirehosePolicy_policy_document.json
}

resource "aws_iam_role_policy_attachment" "CWLtoFirehoseRole_policy_attachment" {
  provider   = aws.audit
  role       = aws_iam_role.CWLtoFirehoseRole.name
  policy_arn = aws_iam_policy.CWLtoFirehosePolicy.arn
}

data "aws_iam_policy_document" "FirehoseDeliveryRole_policy_document" {
  provider = aws.audit
  version  = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = ["firehose.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      values   = [data.aws_caller_identity.audit_account.account_id]
      variable = "sts:ExternalId"
    }
  }
}

resource "aws_iam_role" "FirehoseDeliveryRole" {
  provider           = aws.audit
  name               = "FirehoseDeliveryRole"
  assume_role_policy = data.aws_iam_policy_document.FirehoseDeliveryRole_policy_document.json
}

data "aws_iam_policy_document" "FirehoseDeliveryPolicy_policy_document" {
  provider = aws.audit
  version  = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.LoggingS3Bucket.arn,
      "${aws_s3_bucket.LoggingS3Bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "FirehoseDeliveryPolicy" {
  provider = aws.audit
  name     = "Firehose_Delivery_Policy"
  policy   = data.aws_iam_policy_document.FirehoseDeliveryPolicy_policy_document.json
}

resource "aws_iam_role_policy_attachment" "FirehoseDeliveryRole_policy_attachment" {
  provider   = aws.audit
  role       = aws_iam_role.FirehoseDeliveryRole.name
  policy_arn = aws_iam_policy.FirehoseDeliveryPolicy.arn
}

resource "aws_cloudwatch_log_destination" "LogDestination" {
  provider   = aws.audit
  name       = "CentralLogDestination"
  role_arn   = aws_iam_role.CWLtoFirehoseRole.arn
  target_arn = aws_kinesis_firehose_delivery_stream.FirehoseLoggingDeliveryStream.arn

  depends_on = [
    aws_kinesis_firehose_delivery_stream.FirehoseLoggingDeliveryStream,
    aws_iam_role.CWLtoFirehoseRole,
    aws_iam_policy.CWLtoFirehosePolicy
  ]
}

resource "aws_cloudwatch_log_destination_policy" "aws_cloudwatch_log_destination_policy" {
  provider = aws.audit
  access_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Principal : {
          AWS : [
            data.aws_caller_identity.develop_account.account_id,
            data.aws_caller_identity.uat_account.account_id,
          ]
        },
        Action : "logs:PutSubscriptionFilter",
        Resource : aws_cloudwatch_log_destination.LogDestination.arn
        //        Resource: "arn:aws:logs:${var.region}:${data.aws_caller_identity.audit_account.account_id}:destination:CentralLogDestination"
      }
    ]
  })
  destination_name = aws_cloudwatch_log_destination.LogDestination.name
}

resource "random_string" "LoggingS3Bucket_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_s3_bucket" "LoggingS3Bucket" {
  provider = aws.audit
  bucket   = "audit-logs-${random_string.LoggingS3Bucket_suffix.result}"
}

resource "aws_s3_bucket_policy" "LoggingS3Bucket_policy" {
  provider = aws.audit
  bucket   = aws_s3_bucket.LoggingS3Bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "LoggingS3BucketPolicy"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS : [
            data.aws_caller_identity.develop_account.account_id,
            data.aws_caller_identity.uat_account.account_id
          ]
        }
        Action = [
          "s3:Get*",
          "s3:List*"
        ]
        Resource = [
          aws_s3_bucket.LoggingS3Bucket.arn,
          "${aws_s3_bucket.LoggingS3Bucket.arn}/*",
        ]
      },
    ]
  })
}

//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream
//https://github.com/easyawslearn/terraform-aws-kinesis/blob/master/main.tf
resource "aws_kinesis_firehose_delivery_stream" "FirehoseLoggingDeliveryStream" {
  provider    = aws.audit
  destination = "extended_s3"
  name        = "Centralized-Logging-Delivery-Stream"

  extended_s3_configuration {
    bucket_arn         = aws_s3_bucket.LoggingS3Bucket.arn
    role_arn           = aws_iam_role.FirehoseDeliveryRole.arn
    compression_format = "UNCOMPRESSED"
    buffer_interval    = 300
    buffer_size        = 50
    prefix             = "CentralizedAccountLogs/"
  }
  depends_on = [
    aws_iam_role.CWLtoFirehoseRole,
    aws_iam_policy.CWLtoFirehosePolicy,
  ]
}

output "audit_destination_arn" {
  value = aws_cloudwatch_log_destination.LogDestination.arn
}
