resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_to_s3" {
  name        = "${var.project_name}-${var.firehose_name}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = "${aws_iam_role.iam_role_firehose.arn}"
    bucket_arn         = "${aws_s3_bucket.firehose_s3_bucket.arn}"
    buffer_size        = "${var.buffer_size}"
    buffer_interval    = "${var.buffer_interval}"
    prefix             = "${var.prefix}"
    compression_format = "${var.compression_format}"

    processing_configuration = [
      {
        enabled = "true"

        processors = [
          {
            type = "Lambda"

            parameters = [
              {
                parameter_name  = "LambdaArn"
                parameter_value = "${aws_lambda_function.lambda_processor.arn}"
              },
            ]
          },
        ]
      },
    ]
  }

  tags = {
    Name        = "Kinesis-Firehose"
    Project     = "${var.project_name}"
    Environment = "${var.tag_environment}"
  }
}

resource "aws_s3_bucket" "firehose_s3_bucket" {
  bucket = "${var.project_name}-${var.s3_bucket}"
  acl    = "private"

  tags = {
    Name        = "S3"
    Project     = "${var.project_name}"
    Environment = "${var.tag_environment}"
  }
}

resource "aws_iam_role" "iam_role_firehose" {
  name = "${var.project_name}-${var.firehose_name}-kinesis_role"

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

resource "aws_iam_role_policy" "iam_role_policy_firehose_lambda" {
  name = "${var.project_name}-${var.firehose_name}-lambda_policy"
  role = "${aws_iam_role.iam_role_firehose.id}"

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

resource "aws_iam_role_policy" "iam_role_firehose_s3" {
  name = "${var.project_name}-${var.firehose_name}-s3_policy"
  role = "${aws_iam_role.iam_role_firehose.id}"

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
              "${aws_s3_bucket.firehose_s3_bucket.arn}",
              "${aws_s3_bucket.firehose_s3_bucket.arn}*"
            ]
        }
    ]
}
EOF
}

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
    Environment = "${var.tag_environment}"
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
