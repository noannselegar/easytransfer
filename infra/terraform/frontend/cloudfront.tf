resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "easyTransferOAC"
  description                       = "OAC for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cf_distro" {
  aliases = ["app.noannselegar.cloud"]

  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = "${aws_s3_bucket.website_content.bucket}.s3.amazonaws.com"
    origin_id                = "s3-content-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-content-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed cache policy for static assets
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "cf_record" {
  zone_id = var.hosted_zone_id
  name    = "app.noannselegar.cloud"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf_distro.domain_name
    zone_id                = "Z2FDTNDATAQYW2" # Always the same for CloudFront
    evaluate_target_health = false
  }
}
