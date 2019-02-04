####################
# S3
####################
output "uncompressed_s3_bucket" {
  value = "${module.s3.uncompressed_s3_bucket_arn}"
}

output "compressed_s3_bucket" {
  value = "${module.s3.compressed_s3_bucket_arn}"
}


####################
# Dynamodb
####################
output "dynamodb" {
  description = "DynamoDB table to store the gender click stream statistics."
  value = "${module.dynamodb.dynamodb_table_arn}"
}

####################
# Kinesis Firehose
####################
output "kinesis_firehose" {
  description = "Kinesis Firehose stream."
  value = "${module.kinesis_firehose.kinesis_firehose_arn}"
}

####################
# Lambdas
####################
output "firehose_processor_lambda" {
  value = "${module.kinesis_firehose.firehose_lambda_processor_arn}"
}

output "process_stream_lambda" {
  value = "${module.process_stream.lambda_process_stream_arn}"
}

output "daily_process_gender_lambda" {
  value = "${module.daily_process_gender.lambda_daily_process_arn}"
}

output "gender_getter_lambda" {
  value = "${module.gender_api_gateway.gender_getter_lambda_arn}"
}

####################
# Cloudwatch
####################
output "daily_process_gender_cloudwatch" {
  value = "${module.daily_process_gender.cloudwatch_daily_event_trigger}"
}

####################
# API Gateway
####################
output "gender_api_gateway" {
  description = "API gateway ARN."
  value = "${module.gender_api_gateway.gender_api_gateway}"
}
