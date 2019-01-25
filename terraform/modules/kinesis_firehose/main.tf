resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_to_s3" {
  name        = "${var.project_name}-${var.firehose_name}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = "${aws_iam_role.kinesis_firehose.arn}"
    bucket_arn         = "${var.s3_bucket_arn}"
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
    Environment = "${var.environment}"
  }
}
