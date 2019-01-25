resource "aws_lambda_function" "data_processor" {
  description   = "An Amazon Kinesis Firehose stream processor that appends a timestamp to input records."

  s3_bucket     = "${var.lambda_s3_code_bucket}"
  s3_key        = "${var.lambda_s3_filename}"
  function_name = "${var.project_name}-${var.firehose_name}-data_processor"
  role          = "${aws_iam_role.data_processor.arn}"
  handler       = "app.lambda_handler"
  runtime       = "python3.7"
  memory_size   = "${var.lambda_memory_size}"
  timeout       = "${var.lambda_timeout}"

  environment {
    variables {
      S3_BUCKET_SOURCE = "${var.uncompressed_bucket_name}"
      S3_BUCKET_DEST   = "${var.compressed_bucket_name}"
      DYNAMODB_TABLE   = "${var.dynamodb_table_name}"
    }
  }

  tags = {
    Name        = "Lambda"
    Project     = "${var.project_name}"
    Environment = "${var.environment}"
  }
}
