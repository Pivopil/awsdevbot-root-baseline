locals {
  # Get distinct list of domains and SANs
  distinct_domain_names = distinct(concat([replace(var.domain_name, "*.", "")], [for s in var.subject_alternative_names : replace(s, "*.", "")]))
  # Copy domain_validation_options for the distinct domain names
  validation_domains = var.create_certificate ? [for k, v in aws_acm_certificate.this[0].domain_validation_options : tomap(v) if contains(local.distinct_domain_names, replace(v.domain_name, "*.", ""))] : []
}

resource "aws_acm_certificate" "this" {
  count = var.create_certificate ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method

  options {
    certificate_transparency_logging_preference = var.certificate_transparency_logging_preference ? "ENABLED" : "DISABLED"
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  count = var.create_certificate && var.validation_method == "DNS" && var.validate_certificate ? length(local.distinct_domain_names) + 1 : 0

  zone_id = var.zone_id
  name    = element(local.validation_domains, count.index)["resource_record_name"]
  type    = element(local.validation_domains, count.index)["resource_record_type"]
  ttl     = var.dns_ttl

  records = [
    element(local.validation_domains, count.index)["resource_record_value"]
  ]

  allow_overwrite = var.validation_allow_overwrite_records

  depends_on = [aws_acm_certificate.this]
}

resource "aws_acm_certificate_validation" "this" {
  count = var.create_certificate && var.validation_method == "DNS" && var.validate_certificate && var.wait_for_validation ? 1 : 0

  certificate_arn = aws_acm_certificate.this[0].arn

  validation_record_fqdns = aws_route53_record.validation.*.fqdn
}

//======
variable "create_certificate" {
  description = "Whether to create ACM certificate"
  type        = bool
  default     = true
}

variable "validate_certificate" {
  description = "Whether to validate certificate by creating Route53 record"
  type        = bool
  default     = true
}

variable "validation_allow_overwrite_records" {
  description = "Whether to allow overwrite of Route53 records"
  type        = bool
  default     = true
}

variable "wait_for_validation" {
  description = "Whether to wait for the validation to complete"
  type        = bool
  default     = true
}

variable "certificate_transparency_logging_preference" {
  description = "Specifies whether certificate details should be added to a certificate transparency log"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "A domain name for which the certificate should be issued"
  type        = string
  default     = ""
}

variable "subject_alternative_names" {
  description = "A list of domains that should be SANs in the issued certificate"
  type        = list(string)
  default     = []
}

variable "validation_method" {
  description = "Which method to use for validation. DNS or EMAIL are valid, NONE can be used for certificates that were imported into ACM and then into Terraform."
  type        = string
  default     = "DNS"
}

variable "zone_id" {
  description = "The ID of the hosted zone to contain this record."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "dns_ttl" {
  description = "The TTL of DNS recursive resolvers to cache information about this record."
  type        = number
  default     = 60
}
//======
output "this_acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = element(concat(aws_acm_certificate_validation.this.*.certificate_arn, aws_acm_certificate.this.*.arn, [""]), 0)
}

output "this_acm_certificate_domain_validation_options" {
  description = "A list of attributes to feed into other resources to complete certificate validation. Can have more than one element, e.g. if SANs are defined. Only set if DNS-validation was used."
  value       = flatten(aws_acm_certificate.this.*.domain_validation_options)
}

output "this_acm_certificate_validation_emails" {
  description = "A list of addresses that received a validation E-Mail. Only set if EMAIL-validation was used."
  value       = flatten(aws_acm_certificate.this.*.validation_emails)
}

output "validation_route53_record_fqdns" {
  description = "List of FQDNs built using the zone domain and name."
  value       = aws_route53_record.validation.*.fqdn
}

output "distinct_domain_names" {
  description = "List of distinct domains names used for the validation."
  value       = local.distinct_domain_names
}

output "validation_domains" {
  description = "List of distinct domain validation options. This is useful if subject alternative names contain wildcards."
  value       = local.validation_domains
}
