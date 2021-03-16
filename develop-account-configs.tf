variable "develop_assume_role" {
}

locals {
  develop_account_domain = "dev.${var.public_subdomain}"
}

provider "aws" {
  alias = "develop"
  assume_role {
    role_arn = var.develop_assume_role
  }
}

data "aws_caller_identity" "develop_account" {
  provider = aws.develop
}

resource "aws_s3_bucket" "develop-s3" {
  provider      = aws.develop
  bucket_prefix = "develop-s3-bucket-"
}

resource "aws_route53_zone" "develop_route53_zone" {
  provider = aws.develop
  name     = local.develop_account_domain
}

resource "aws_route53_record" "develop_route53_ns_record" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.develop_account_domain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.develop_route53_zone.name_servers
}

