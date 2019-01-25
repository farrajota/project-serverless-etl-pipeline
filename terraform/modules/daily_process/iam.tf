resource "aws_iam_role" "daily_process_role" {
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

resource "aws_iam_role_policy" "daily_process_dynamodb" {
  name = "${var.project_name}-${var.lambda_name}-lambda_dynamodb"
  role = "${aws_iam_role.daily_process_role.id}"

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

resource "aws_iam_role_policy" "daily_process_s3" {
  name = "${var.project_name}-${var.lambda_name}-lambda_s3"
  role = "${aws_iam_role.daily_process_role.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "s3:PutObject",
                "s3:Get*"
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

resource "aws_iam_role_policy" "daily_process_logs" {
  name = "${var.project_name}-${var.lambda_name}-lambda_logs"
  role = "${aws_iam_role.daily_process_role.id}"

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