output "dynamodb_arn" {
  value = "${aws_dynamodb_table.gender_db.arn}"
}

output "dynamodb_table_name" {
  value = "${var.table_name}"
}