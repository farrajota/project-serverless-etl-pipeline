provider "aws" {
  region = "${var.region}"
}

####################
# S3
####################

module "s3" {
  source                 = "./modules/s3"
  project_name           = "${var.project_name}"
  uncompressed_s3_bucket = "${var.s3_uncompressed_s3_bucket}"
  compressed_s3_bucket   = "${var.s3_compressed_s3_bucket}"
  environment            = "${var.environment}"
}


####################
# DynamoDB
####################

module "dynamodb" {
  source               = "./modules/dynamodb"
  project_name         = "${var.project_name}"
  table_name           = "${var.dynamodb_table_name}"
  billing_mode         = "${var.dynamodb_billing_mode}"
  read_capacity_units  = "${var.dynamodb_read_capacity_units}"
  write_capacity_units = "${var.dynamodb_write_capacity_units}"
  key_element_name     = "${var.dynamodb_key_element_name}"
  key_element_type     = "${var.dynamodb_key_element_type}"
  environment          = "${var.environment}"
}


####################
# Kinesis Firehose
####################

module "kinesis_firehose" {
  source                = "./modules/kinesis_firehose"
  project_name          = "${var.project_name}"
  firehose_name         = "${var.kinesis_firehose_name}"
  buffer_size           = "${var.kinesis_firehose_buffer_size}"
  buffer_interval       = "${var.kinesis_firehose_buffer_interval}"
  prefix                = "${var.kinesis_firehose_prefix}"
  compression_format    = "${var.kinesis_firehose_compression_format}"
  s3_bucket_arn         = "${module.s3.uncompressed_s3_bucket_arn}"
  lambda_s3_code_bucket = "${var.s3_code_bucket}"
  lambda_s3_filename    = "${var.kinesis_firehose_lambda_s3_filename}"
  lambda_name           = "${var.kinesis_firehose_lambda_name}"
  lambda_memory_size    = "${var.kinesis_firehose_lambda_memory_size}"
  lambda_timeout        = "${var.kinesis_firehose_lambda_timeout}"
  environment           = "${var.environment}"
}


####################
# Process Data
####################

module "process_stream" {
  source                   = "./modules/process_stream"

  uncompressed_bucket_name = "${module.s3.uncompressed_s3_bucket_name}"
  uncompressed_bucket_arn  = "${module.s3.uncompressed_s3_bucket_arn}"
  compressed_bucket_name   = "${module.s3.compressed_s3_bucket_name}"
  compressed_bucket_arn    = "${module.s3.compressed_s3_bucket_arn}"
  dynamodb_table_name      = "${module.dynamodb.dynamodb_table_name}"
  dynamodb_table_arn       = "${module.dynamodb.dynamodb_table_arn}"

  project_name             = "${var.project_name}"
  firehose_name            = "${var.kinesis_firehose_name}"
  lambda_s3_code_bucket    = "${var.s3_code_bucket}"
  lambda_s3_filename       = "${var.process_stream_lambda_s3_filename}"
  lambda_name              = "${var.process_stream_lambda_name}"
  lambda_memory_size       = "${var.process_stream_lambda_memory_size}"
  lambda_timeout           = "${var.process_stream_lambda_timeout}"
  environment              = "${var.environment}"
}
