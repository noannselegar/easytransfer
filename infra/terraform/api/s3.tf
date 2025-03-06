resource "aws_s3_bucket" "files_bucket" {
  bucket = "easytransfer-uploaded-files"
}

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.files_bucket.id

  rule {
    id = "expire-after-7"

    expiration {
      days = 7
    }

    filter {}

    status = "Enabled"
  }
}