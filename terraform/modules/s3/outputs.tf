output "uncompressed_s3_bucket_arn" {
  value = "${aws_s3_bucket.uncompressed_s3_bucket.arn}"
}

output "uncompressed_s3_bucket_name" {
  value = "${aws_s3_bucket.uncompressed_s3_bucket.id}"
}

output "compressed_s3_bucket_arn" {
  value = "${aws_s3_bucket.compressed_s3_bucket.arn}"
}

output "compressed_s3_bucket_name" {
  value = "${aws_s3_bucket.compressed_s3_bucket.id}"
}