variable "uat_assume_role" {
}

locals {
  uat_account_domain = "uat.${var.public_subdomain}"
}

provider "aws" {
  alias = "uat"
  assume_role {
    role_arn = var.uat_assume_role
  }
}

resource "aws_route53_zone" "uat_route53_zone" {
  provider = aws.uat
  name = local.uat_account_domain
}

resource "aws_route53_record" "uat_route53_ns_record" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.uat_account_domain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.uat_route53_zone.name_servers
}

