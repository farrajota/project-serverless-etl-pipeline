output "lambda_daily_process_arn" {
  value = "${aws_lambda_function.daily_process.arn}"
}

output "cloudwatch_daily_event_trigger" {
  value = "${aws_cloudwatch_event_rule.daily_at_1am.arn}"
}

