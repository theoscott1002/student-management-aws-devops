output "dynamodb_table_name" {
  value = aws_dynamodb_table.students.name
}

output "aws_region" {
  value = var.aws_region
}