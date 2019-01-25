resource "aws_iam_role" "data_processor" {
  name = "${var.project_name}-${var.lambda_name}-lambda_role"

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

resource "aws_iam_role_policy" "data_processor_logs" {
  name = "${var.project_name}-${var.lambda_name}-lambda_logs"
  role = "${aws_iam_role.data_processor.id}"

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

resource "aws_iam_role_policy" "data_processor_s3_uncompressed" {
  name = "${var.project_name}-${var.firehose_name}-lambda_s3_uncompressed"
  role = "${aws_iam_role.data_processor.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:DeleteObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "${var.uncompressed_bucket_arn}*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "data_processor_s3_compressed" {
  name = "${var.project_name}-${var.firehose_name}-lambda_s3_compressed"
  role = "${aws_iam_role.data_processor.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "${var.compressed_bucket_arn}*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "data_processor_cloudwatch" {
  name = "${var.project_name}-${var.lambda_name}-lambda_cloudwatch"
  role = "${aws_iam_role.data_processor.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "cloudwatch:PutMetricData"
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

resource "aws_iam_role_policy" "data_processor_dynamodb" {
  name = "${var.project_name}-${var.lambda_name}-lambda_dynamodb"
  role = "${aws_iam_role.data_processor.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "dynamodb:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "${var.dynamodb_table_arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.data_processor.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${var.uncompressed_bucket_arn}"
}