resource "aws_lambda_function" "daily_process" {
  description   = "Processes the top gender per visitor in the last 7 days."

  s3_bucket     = "${var.lambda_s3_code_bucket}"
  s3_key        = "${var.lambda_s3_filename}"
  function_name = "${var.project_name}-${var.lambda_name}"
  role          = "${aws_iam_role.daily_process_role.arn}"
  handler       = "app.lambda_handler"
  runtime       = "python3.7"
  memory_size   = "${var.lambda_memory_size}"
  timeout       = "${var.lambda_timeout}"

  environment {
    variables {
      S3_BUCKET_SOURCE = "${var.compressed_bucket_name}"
      DYNAMODB_TABLE   = "${var.dynamodb_table_name}"
      FIREHOSE_PREFIX  = "${var.firehose_prefix}"
    }
  }

  tags = {
    Name        = "Lambda"
    Project     = "${var.project_name}"
    Environment = "${var.environment}"
    managed_by  = "terraform"
  }
}
