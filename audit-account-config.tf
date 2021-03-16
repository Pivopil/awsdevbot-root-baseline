variable "audit_account_id" {
}

locals {
  audit_assume_role    = "arn:aws:iam::${var.audit_account_id}:role/OrganizationAccountAccessRole"
}

provider "aws" {
  alias = "audit"
  assume_role {
    role_arn = local.audit_assume_role
  }
}

resource "aws_s3_bucket" "audit_test_bucket" {
  provider = aws.audit
  bucket = "audit-test-ghfj85"
}
