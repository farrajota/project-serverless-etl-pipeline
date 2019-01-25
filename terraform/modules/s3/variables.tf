variable "project_name" {
  description = "Name of the project (to be used for prefixing services / configuration)"
}

variable "environment" {
  description = "Environment tag name (dev / test / prod)"
}

variable "uncompressed_s3_bucket" {
  description = "S3 bucket name to store the uncompressed stream output."
}

variable "compressed_s3_bucket" {
  description = "S3 bucket name to store the compressed / processed stream output."
}
