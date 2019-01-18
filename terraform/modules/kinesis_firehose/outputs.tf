output "kinesis_firehose_arn" {
  value = "${aws_kinesis_firehose_delivery_stream.kinesis_firehose_to_s3.arn}"
}

output "firehose_lambda_processor_arn" {
  value = "${aws_lambda_function.lambda_processor.arn}"
}