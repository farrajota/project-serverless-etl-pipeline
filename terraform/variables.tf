variable "project_name" {
  description = "Name of the project (to be used for prefixing services / configuration)"
}

variable "environment" {
  description = "Environment tag name (dev / test / prod)"
}

variable "aws_account" {
  description = "AWS account id"
}

variable "aws_region" {
  description = "Region to deploy the services"
  default = "eu-west-1"
}

variable "s3_code_bucket" {
  description = "S3 bucket storing the lambda code"
  default = "case-study-project-lambda-code"
}


####################
# S3
####################

variable "s3_uncompressed_s3_bucket" {
  description = "S3 bucket name to store the uncompressed stream output."
}

variable "s3_compressed_s3_bucket" {
  description = "S3 bucket name to store the compressed / processed stream output."
}


####################
# DynamoDB
####################

variable "dynamodb_table_name" {
  description = "Name of the dynamodb table"
}

variable "dynamodb_billing_mode" {
  description = "Billing mode"
  default = "PROVISIONED"
}

variable "dynamodb_read_capacity_units" {
  description = "Dynamodb's read capacity"
  default = 5
}

variable "dynamodb_write_capacity_units" {
  description = "Dynamodb's write capacity"
  default = 5
}

variable "dynamodb_key_element_name" {
  description = "Primary Key Name"
}

variable "dynamodb_key_element_type" {
  description = "Primary Key Type"
}

variable "dynamodb_tag_service_name" {
  description = "Service name tag"
}


####################
# Kinesis Firehose
####################

variable "kinesis_firehose_name" {
  description = "Name of the firehose service."
}

variable "kinesis_firehose_buffer_size" {
  description = "Maximum batch size in MB"
}

variable "kinesis_firehose_buffer_interval" {
  description = "How long Firehose will wait before writing a new batch into S3"
}

variable "kinesis_firehose_prefix" {
  description = "The S3 Key prefix for Kinesis Firehose."
}

variable "kinesis_firehose_compression_format" {
  description = "Compression format used by Kinesis Firehose"
}

variable "kinesis_firehose_lambda_s3_filename" {
  description = "Name of the file of the stream process lambda in s3."
}

variable "kinesis_firehose_lambda_name" {
  description = "Lambda function to process kinesis firehose streams."
}

variable "kinesis_firehose_lambda_memory_size" {
  description = "Size of the lambda's total memory."
  default = 128
}

variable "kinesis_firehose_lambda_timeout" {
  description = "Maximum Lambda execution time in seconds."
  default = 60
}


####################
# Process  Data
####################

variable "process_stream_lambda_s3_filename" {
  description = "Name of the file of the stream process lambda in s3."
}

variable "process_stream_lambda_name" {
  description = "Lambda function to process kinesis firehose streams."
}

variable "process_stream_lambda_memory_size" {
  description = "Size of the lambda's total memory."
  default = 256
}

variable "process_stream_lambda_timeout" {
  description = "Maximum Lambda execution time in seconds."
  default = 300
}

####################
# Daily Process
####################

variable "daily_process_lambda_s3_filename" {
  description = "Name of the file of the stream process lambda in s3."
}

variable "daily_process_lambda_name" {
  description = "Lambda function to process kinesis firehose streams."
}

variable "daily_process_lambda_memory_size" {
  description = "Size of the lambda's total memory."
  default = 128
}

variable "daily_process_lambda_timeout" {
  description = "Maximum Lambda execution time in seconds."
  default = 60
}

variable "daily_process_cloudwatch_event_schedule" {
  description = "Schedule of the cloudwatch event to trigger an aws lambda to process the top gender of the last 7 days."
  default = "cron(0 1 * * ? *)"
}


####################
# API Gateway
####################

variable "api_gateway_lambda_s3_filename" {
  description = "Name of the file of the gender api lambda in s3."
}

variable "api_gateway_lambda_name" {
  description = "Lambda function to get the gender for a clientid."
}

variable "api_gateway_lambda_memory_size" {
  description = "Size of the lambda's total memory."
  default = 128
}

variable "api_gateway_lambda_timeout" {
  description = "Maximum Lambda execution time in seconds."
  default = 10
}

variable "api_gateway_name" {
  description = "Name of the gender api"
}

variable "api_gateway_stage_name" {
  description = "Stage of the api (Test/QA/Prod)"
}
