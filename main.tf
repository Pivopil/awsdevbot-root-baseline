provider "aws" {
}

data "aws_caller_identity" "account" {
}

data "aws_route53_zone" "public" {
  name         = var.public_subdomain
  private_zone = false
}

module "acm" {
  source             = "./modules/acm"
  create_certificate = true
  domain_name        = var.public_subdomain
  zone_id            = data.aws_route53_zone.public.zone_id
  subject_alternative_names = [
    "api.${var.public_subdomain}",
    "www.${var.public_subdomain}",
    "app.${var.public_subdomain}",
  ]
  tags = {
    Name = var.public_subdomain
  }
}

variable "public_subdomain" {
}

output "acm_arn" {
  value = module.acm.this_acm_certificate_arn
}
