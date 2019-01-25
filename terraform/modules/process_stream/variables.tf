variable "project_name" {
  description = "Name of the project (to be used for prefixing services / configuration)"
}

variable "environment" {
  description = "Environment tag name (dev / test / prod)"
}

variable "firehose_name" {
  description = "Name of the firehose service."
}

variable "uncompressed_bucket_name" {
  description = "Name of the S3 bucket storing kinesis firehose uncompressed stream data."
}

variable "uncompressed_bucket_arn" {
  description = "ARN of the S3 bucket storing kinesis firehose uncompressed stream data."
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
  default = 256
}

variable "lambda_timeout" {
  description = "Maximum Lambda execution time in seconds."
  default = 300
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table."
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table."
}
