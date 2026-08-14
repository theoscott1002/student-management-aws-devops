resource "aws_dynamodb_table" "students" {
  name         = "Students-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "studentId"

  attribute {
    name = "studentId"
    type = "S"
  }

  tags = {
    Project     = "Student Management"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}