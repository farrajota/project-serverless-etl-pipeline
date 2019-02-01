resource "aws_s3_bucket" "uncompressed_s3_bucket" {
  bucket = "${var.project_name}-${var.uncompressed_s3_bucket}"
  acl    = "private"

  tags = {
    Name        = "S3"
    Description = "Kinesis Firehose destination bucket"
    Project     = "${var.project_name}"
    Environment = "${var.environment}"
    managed_by  = "terraform"
  }
}

resource "aws_s3_bucket" "compressed_s3_bucket" {
  bucket = "${var.project_name}-${var.compressed_s3_bucket}"
  acl    = "private"

  tags = {
    Name        = "S3"
    Description = "Compressed stream data"
    Project     = "${var.project_name}"
    Environment = "${var.environment}"
    managed_by  = "terraform"
  }
}
