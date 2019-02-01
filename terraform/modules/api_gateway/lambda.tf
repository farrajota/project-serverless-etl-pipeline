resource "aws_lambda_function" "gender_getter" {
  description   = "Gets the gender information from dynamodb"

  s3_bucket     = "${var.lambda_s3_code_bucket}"
  s3_key        = "${var.lambda_s3_filename}"
  function_name = "${var.project_name}-${var.lambda_name}"
  role          = "${aws_iam_role.gender_getter_role.arn}"
  handler       = "app.lambda_handler"
  runtime       = "python3.7"
  memory_size   = "${var.lambda_memory_size}"
  timeout       = "${var.lambda_timeout}"

  environment {
    variables {
      DYNAMODB_TABLE   = "${var.dynamodb_table_name}"
    }
  }

  tags = {
    Name        = "Lambda"
    Project     = "${var.project_name}"
    Environment = "${var.environment}"
  }
}
