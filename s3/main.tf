resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  tags = {
    Name = var.bucket_name
  }

  # lifecycle {
  #   # true
  #   prevent_destroy = true
  # }
}

resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    # "Enabled"
    status = var.bucket_versioning_configuration
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_block" {
  bucket = aws_s3_bucket.s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}