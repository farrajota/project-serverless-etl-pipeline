output "dynamodb" {
  description = "DynamoDB table to store the gender click stream statistics."
  value = "${module.dynamodb.dynamodb_table_arn}"
}

output "kinesis_firehose" {
  description = "Kinesis Firehose stream."
  value = "${module.kinesis_firehose.kinesis_firehose_arn}"
}