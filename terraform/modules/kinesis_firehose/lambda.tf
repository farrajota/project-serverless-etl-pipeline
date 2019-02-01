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

resource "aws_iam_role" "lambda_iam_role" {
  name = "${var.project_name}-${var.firehose_name}-lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_policy_logs" {
  name = "${var.project_name}-${var.firehose_name}-lambda_logs"
  role = "${aws_iam_role.lambda_iam_role.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}
