resource "aws_iam_role" "lambda_role" {
  name = "student-management-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "lambda.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

locals {
  lambda_functions = {
    create_student = "create_student"
    get_students   = "get_students"
    get_student    = "get_student_by_id"
    update_student = "update_student"
    delete_student = "delete_student"
  }
}

data "archive_file" "lambda_zip" {
  for_each = local.lambda_functions

  type        = "zip"
  source_dir  = "${path.module}/../backend/${each.value}"
  output_path = "${path.module}/.terraform/${each.key}.zip"
}

resource "aws_lambda_function" "students" {
  for_each = local.lambda_functions

  function_name = "student-${each.key}"
  role          = aws_iam_role.lambda_role.arn

  runtime = "python3.12"
  handler = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda_zip[each.key].output_path
  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.students.name
    }
  }

  tags = {
    Project     = "Student Management"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}