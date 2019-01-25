project_name = "case-study"
environment = "production"
region = "eu-west-1"
s3_code_bucket = "case-study-project-lambda-code"
# S3
s3_uncompressed_s3_bucket = "kinesis-firehose-stream"
s3_compressed_s3_bucket = "stream-compressed"
# DynamoDB
dynamodb_table_name = "gender"
dynamodb_billing_mode = "PROVISIONED"
dynamodb_read_capacity_units = 5
dynamodb_write_capacity_units = 5
dynamodb_key_element_name = "clientid"
dynamodb_key_element_type = "S"
dynamodb_tag_service_name = "dynamodb-table-1"
# Kinesis Firehose Stream
kinesis_firehose_name = "kinesis_firehose_stream"
kinesis_firehose_buffer_size = 10
kinesis_firehose_buffer_interval = 60
kinesis_firehose_prefix = "firehose/"
kinesis_firehose_compression_format = "UNCOMPRESSED"
kinesis_firehose_lambda_s3_filename = "firehose_lambda.zip"
kinesis_firehose_lambda_name = "firehose-lambda-stream-processor"
kinesis_firehose_lambda_memory_size = 128
kinesis_firehose_lambda_timeout = 60
# Process Stream
process_stream_lambda_s3_filename = "process_stream.zip"
process_stream_lambda_name = "process_stream_data"
process_stream_lambda_memory_size = "256"
process_stream_lambda_timeout = "300"
