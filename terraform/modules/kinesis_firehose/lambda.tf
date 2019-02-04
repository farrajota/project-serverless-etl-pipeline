resource "aws_lambda_function" "lambda_processor" {
  description   = "An Amazon Kinesis Firehose stream processor that appends a timestamp to input records."

  s3_bucket     = "${var.lambda_s3_code_bucket}"
  s3_key        = "${var.lambda_s3_filename}"
  function_name = "${var.project_name}-${var.firehose_name}-processor"
  role          = "${aws_iam_role.lambda_iam_role.arn}"
  handler       = "app.lambda_handler"
  runtime       = "python3.7"
  memory_size   = "${var.lambda_memory_size}"
  timeout       = "${var.lambda_timeout}"

  tags = {
    Name        = "Lambda"
    Project     = "${var.project_name}"
    Environment = "${var.environment}"
    managed_by  = "terraform"
  }
}
