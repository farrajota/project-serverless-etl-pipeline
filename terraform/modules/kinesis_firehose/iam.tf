####################
# Kinesis Firehose
####################

resource "aws_iam_role" "kinesis_firehose" {
  name = "${var.project_name}-${var.firehose_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "kinesis_firehose_invoke_lambda" {
  name = "${var.project_name}-${var.firehose_name}-lambda"
  role = "${aws_iam_role.kinesis_firehose.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
              "lambda:InvokeFunction"
            ],
            "Effect": "Allow",
            "Resource": [
              "${aws_lambda_function.lambda_processor.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "kinesis_firehose_s3" {
  name = "${var.project_name}-${var.firehose_name}-s3"
  role = "${aws_iam_role.kinesis_firehose.id}"

  policy = <<EOF
{
    "Statement": [
        {
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [
              "${var.s3_bucket_arn}",
              "${var.s3_bucket_arn}*"
            ]
        }
    ]
}
EOF
}


####################
# Lambda
####################

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
