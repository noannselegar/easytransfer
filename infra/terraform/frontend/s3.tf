resource "aws_s3_bucket" "website_content" {
  bucket = "easytransfer-content-origin"
}

resource "aws_s3_bucket_policy" "website_content_policy" {
  bucket = aws_s3_bucket.website_content.id

  policy = jsonencode({
    Version   = "2008-10-17"
    Id        = "PolicyForCloudFrontPrivateContent"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_content.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cf_distro.arn
          }
        }
      }
    ]
  })
}
