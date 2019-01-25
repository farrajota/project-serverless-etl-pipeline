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
