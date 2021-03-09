locals {
  zone_id               = data.aws_route53_zone.public.zone_id
  email_bucket_name     = "${var.prefix}-${var.ses_bucket}-${random_string.suffix.result}"
  ses_object_key_prefix = "ses"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

//https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-permissions.html
data "aws_iam_policy_document" "s3_allow_ses_puts" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${local.email_bucket_name}/${local.ses_object_key_prefix}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:Referer"
      values   = [data.aws_caller_identity.account.account_id]
    }
  }
}

data "aws_iam_user" "terraform_cloud_workspace_user" {
  user_name = var.workspace
}

//https://aws.amazon.com/premiumsupport/knowledge-center/s3-bucket-access-default-encryption/
data "aws_iam_policy_document" "ses_kms_policy" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:GenerateDataKey",
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

  }
  statement {
    effect = "Allow"
    actions = [
      "kms:*",
    ]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [
        data.aws_iam_user.terraform_cloud_workspace_user.arn,
        "arn:aws:iam::${data.aws_caller_identity.account.account_id}:root"
      ]
    }
  }
}

//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity
resource "aws_ses_domain_identity" "ses_domain_identity" {
  domain = var.public_subdomain
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = local.zone_id
  name    = "_amazonses.${var.public_subdomain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.ses_domain_identity.verification_token]
}

//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_dkim
resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  domain = aws_ses_domain_identity.ses_domain_identity.domain
}

resource "aws_route53_record" "dkim_record" {
  count   = 3
  zone_id = local.zone_id
  name    = "${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}._domainkey.${var.public_subdomain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# ses mail to records
resource "aws_route53_record" "mx_records" {
  zone_id = local.zone_id
  name    = var.public_subdomain
  type    = "MX"
  ttl     = "600"

  records = [
    "10 inbound-smtp.${var.region}.amazonses.com",
    "10 inbound-smtp.${var.region}.amazonaws.com",
  ]
}

resource "aws_route53_record" "ms-spf-records" {
  zone_id = local.zone_id
  name    = var.public_subdomain
  type    = "TXT"
  ttl     = "600"

  records = [
    "v=spf1 include:amazonses.com -all",
  ]
}

//https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_receipt_rule_set
resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "${var.prefix}-rule-set"
}

resource "aws_ses_active_receipt_rule_set" "active_receipt_rule_set" {
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name

  depends_on = [
    aws_ses_receipt_rule_set.main
  ]
}

resource "aws_route53_record" "txt_dmarc" {
  zone_id = local.zone_id
  name    = "_dmarc.${var.public_subdomain}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1; p=${var.dmarc_p}; rua=mailto:${var.dmarc_rua_email};"]
}

resource "aws_s3_bucket" "ses_bucket" {
  bucket        = local.email_bucket_name
  acl           = "private"
  force_destroy = true
  policy        = data.aws_iam_policy_document.s3_allow_ses_puts.json

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.ses_aws_kms_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_kms_key" "ses_aws_kms_key" {
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.ses_kms_policy.json
}

resource "aws_ses_receipt_rule" "main" {
  name          = "${var.prefix}-receipt-rule"
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  recipients    = [var.public_subdomain]
  enabled       = true
  scan_enabled  = true

  s3_action {
    position = 1

    bucket_name       = local.email_bucket_name
    object_key_prefix = "ses"
  }

  depends_on = [
    aws_s3_bucket.ses_bucket,
    aws_ses_receipt_rule_set.main
  ]
}

//https://www.mailslurp.com/blog/transactional-emails-with-aws-terraform-lambda/
resource "aws_ses_configuration_set" "ses_configuration_set" {
  name = "${var.prefix}-ses-configuration-set"
}

resource "aws_ses_event_destination" "ses_cloudwatch" {
  name                   = "${var.prefix}-event-destination-cloudwatch"
  configuration_set_name = aws_ses_configuration_set.ses_configuration_set.name
  enabled                = true

  matching_types = [
    "reject",
    "send",
  ]

  cloudwatch_destination {
    default_value  = "default"
    dimension_name = "dimension"
    value_source   = "emailHeader"
  }
}

variable "dmarc_p" {
  description = "DMARC Policy for organizational domains (none, quarantine, reject)."
  type        = string
  default     = "none"
}

variable "dmarc_rua_email" {
}

variable "prefix" {
}

variable "ses_bucket" {
}

variable "workspace" {
}

variable "region" {
}
