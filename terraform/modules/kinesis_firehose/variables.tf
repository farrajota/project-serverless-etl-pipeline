variable "project_name" {
  description = "Name of the project (to be used for prefixing services / configuration)"
}

variable "firehose_name" {
  description = "Name of the firehose service."
}

variable "buffer_size" {
  description = "Maximum batch size in MB"
}

variable "buffer_interval" {
  description = "How long Firehose will wait before writing a new batch into S3"
}

variable "prefix" {
  description = "The S3 Key prefix for Kinesis Firehose."
}

variable "compression_format" {
  description = "Compression format used by Kinesis Firehose"
}

variable "s3_bucket" {
  description = "S3 bucket to store the firehose stream data"
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

####################
# Tags
####################
variable "tag_environment" {
  description = "Environment tag name (dev / test / prod)"
}
