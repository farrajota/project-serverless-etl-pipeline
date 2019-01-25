output "dynamodb_table_arn" {
  value = "${aws_dynamodb_table.gender_db.arn}"
}

output "dynamodb_table_name" {
  value = "${aws_dynamodb_table.gender_db.id}"
}