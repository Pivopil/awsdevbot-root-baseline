resource "aws_route53_record" "gcp_verification_record" {
  zone_id = local.zone_id
  name    = "${var.google_site_subdomain}.${var.public_subdomain}"
  type    = "TXT"
  ttl     = "600"
  records = [var.google_site_verification]
}

variable "google_site_verification" {}
variable "google_site_subdomain" {}
