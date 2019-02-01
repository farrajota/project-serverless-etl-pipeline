resource "aws_dynamodb_table" "gender_db" {
  name           = "${var.project_name}-${var.table_name}"
  billing_mode   = "${var.billing_mode}"
  read_capacity  = "${var.read_capacity_units}"
  write_capacity = "${var.write_capacity_units}"
  hash_key       = "${var.key_element_name}"

  attribute {
    name = "${var.key_element_name}"
    type = "${var.key_element_type}"
  }

  tags = {
    Name        = "DynamoDB"
    Project     = "${var.project_name}"
    Environment = "${var.environment}"
    managed_by  = "terraform"
  }
}
