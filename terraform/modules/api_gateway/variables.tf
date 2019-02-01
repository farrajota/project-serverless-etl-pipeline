variable "aws_account" {
  description = "AWS account id"
}

variable "project_name" {
  description = "Name of the project (to be used for prefixing services / configuration)"
}

variable "environment" {
  description = "Environment tag name (dev / test / prod)"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table."
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table."
}

variable "lambda_s3_code_bucket" {
  description = "S3 bucket to store the lambda code"
}

variable "lambda_s3_filename" {
  description = "Name of the file of the gender api lambda in s3."
}

variable "lambda_name" {
  description = "Lambda function to get the gender for a clientid."
}

variable "lambda_memory_size" {
  description = "Size of the lambda's total memory."
  default = 128
}

variable "lambda_timeout" {
  description = "Maximum Lambda execution time in seconds."
  default = 10
}

variable "api_name" {
  description = "Name of the gender api"
}

variable "aws_region" {
  description = "AWS Region"
}

variable "api_stage_name" {
  description = "Stage of the api (Test/QA/Prod)"
}
