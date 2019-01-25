
resource "aws_cloudwatch_event_rule" "daily_at_1am" {
    name = "daily-at-1am"
    description = "Fires an aws lambda function daily at 1am"
    schedule_expression = "${var.cloudwatch_event_schedule}"
}

resource "aws_cloudwatch_event_target" "process_top_7days_gender_daily" {
    rule = "${aws_cloudwatch_event_rule.daily_at_1am.name}"
    target_id = "${aws_cloudwatch_event_rule.daily_at_1am.id}"
    arn = "${aws_lambda_function.daily_process.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_daily_process_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.daily_process.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.daily_at_1am.arn}"
}