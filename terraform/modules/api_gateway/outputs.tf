output "gender_getter_lambda_arn" {
  value = "${aws_lambda_function.gender_getter.arn}"
}

output "gender_api_gateway" {
  value = "${aws_api_gateway_rest_api.gender_api.id}"
}
