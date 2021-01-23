




variable "web_bucket_name" {
  default = "web-bucket"
}

resource "random_string" "web_bucket_suffix" {
  length  = 4
  special = false
  upper   = false
}

locals {
  web_static_content_bucket_name = "${var.prefix}-${var.web_bucket_name}-${random_string.web_bucket_suffix.result}"
  s3_origin_id = "myS3Origin"
}

resource "aws_s3_bucket_object" "index_html" {
  bucket = aws_s3_bucket.s3_web_static_content_bucket.id
  key = "index.html"
  content = "<h1>Hello, private bucket</h1>"
  content_type = "text/html"
  acl = "public-read"
  cache_control = "max-age=604800"
}

data "aws_iam_policy_document" "s3_allow_gets" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::${local.web_static_content_bucket_name}/*",
    ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket" "s3_web_static_content_bucket" {
  bucket = local.web_static_content_bucket_name

  acl = "private"
  policy = data.aws_iam_policy_document.s3_allow_gets.json

  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

}

resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.s3_web_static_content_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = true
}

//https://github.com/gsweene2/terraform-s3-website-react/blob/master/full.tf
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3_web_static_content_bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  # If there is a 404, return index.html with a HTTP 200 Response
  custom_error_response {
    error_caching_min_ttl = 3000
    error_code = 404
    response_code = 200
    response_page_path = "/index.html"
  }

  logging_config {
    include_cookies = false
    bucket          = "${local.web_static_content_bucket_name}.s3.amazonaws.com"
    prefix          = "cloudfront_logs"
  }

  aliases = [var.public_subdomain, "www.${var.public_subdomain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = module.acm.this_acm_certificate_arn
    ssl_support_method = "sni-only"
  }

}

resource "aws_route53_record" "record_a" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = var.public_subdomain
  type    = "A"

  alias {
    name                   = replace(aws_cloudfront_distribution.s3_distribution.domain_name, "/[.]$/", "")
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
