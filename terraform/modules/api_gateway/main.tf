resource "aws_api_gateway_rest_api" "gender_api" {
  name        = "${var.project_name}-${var.api_name}"
  description = "Gender API Gateway service"
}

resource "aws_api_gateway_resource" "gender_api_root" {
  rest_api_id = "${aws_api_gateway_rest_api.gender_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.gender_api.root_resource_id}"
  path_part   = "gender"
}

resource "aws_api_gateway_resource" "gender_api_clientid" {
  rest_api_id = "${aws_api_gateway_rest_api.gender_api.id}"
  parent_id   = "${aws_api_gateway_resource.gender_api_root.id}"
  path_part   = "{clientid}"
}

resource "aws_api_gateway_method" "gender_api_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.gender_api.id}"
  resource_id   = "${aws_api_gateway_resource.gender_api_clientid.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "gender_api_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.gender_api.id}"
  resource_id             = "${aws_api_gateway_resource.gender_api_clientid.id}"
  http_method             = "${aws_api_gateway_method.gender_api_method.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.gender_getter.arn}/invocations"
}

resource "aws_lambda_permission" "gender_api_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.gender_getter.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account}:${aws_api_gateway_rest_api.gender_api.id}/*/${aws_api_gateway_method.gender_api_method.http_method}${aws_api_gateway_resource.gender_api_clientid.path}"
}

resource "aws_api_gateway_deployment" "gender_api_prod" {
  depends_on  = ["aws_api_gateway_method.gender_api_method",
                 "aws_api_gateway_integration.gender_api_integration"]

  rest_api_id = "${aws_api_gateway_rest_api.gender_api.id}"
  stage_name  = "${var.api_stage_name}"
}