output "lambda_process_stream_arn" {
  value = "${aws_lambda_function.data_processor.arn}"
}
