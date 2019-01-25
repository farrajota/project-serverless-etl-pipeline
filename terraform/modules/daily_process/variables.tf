variable "project_name" {
  description = "Name of the project (to be used for prefixing services / configuration)"
}

variable "environment" {
  description = "Environment tag name (dev / test / prod)"
}

variable "firehose_prefix" {
  description = "Preffix added by kinesis firehose to stored stream data to s3."
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table."
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table."
}

variable "compressed_bucket_name" {
  description = "Name of the S3 bucket storing compressed / processed data."
}

variable "compressed_bucket_arn" {
  description = "ARN of the S3 bucket storing compressed / processed data."
}

variable "lambda_s3_code_bucket" {
  description = "S3 bucket to store the lambda code"
}

variable "lambda_s3_filename" {
  description = "Name of the file of the stream process lambda in s3."
}

variable "lambda_name" {
  description = "Lambda function to process kinesis firehose streams."
}

variable "lambda_memory_size" {
  description = "Size of the lambda's total memory."
  default = 128
}

variable "lambda_timeout" {
  description = "Maximum Lambda execution time in seconds."
  default = 60
}

variable "cloudwatch_event_schedule" {
  description = "Schedule of the cloudwatch event to trigger an aws lambda to process the top gender of the last 7 days."
}