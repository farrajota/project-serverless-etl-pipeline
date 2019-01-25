resource "aws_s3_bucket_notification" "uncompressed_bucket" {
  bucket = "${var.uncompressed_bucket_name}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.data_processor.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}