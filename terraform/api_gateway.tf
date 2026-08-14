resource "aws_apigatewayv2_api" "student_api" {
  name          = "student-api-${var.environment}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type"]
  }

  tags = {
    Project     = "Student Management"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.student_api.id
  name        = var.environment
  auto_deploy = true
}

locals {
  api_routes = {
    create_student = {
      method = "POST"
      path   = "/students"
    }

    get_students = {
      method = "GET"
      path   = "/students"
    }

    get_student = {
      method = "GET"
      path   = "/students/{id}"
    }

    update_student = {
      method = "PUT"
      path   = "/students/{id}"
    }

    delete_student = {
      method = "DELETE"
      path   = "/students/{id}"
    }
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  for_each = local.api_routes

  api_id = aws_apigatewayv2_api.student_api.id

  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.students[each.key].invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "student_routes" {
  for_each = local.api_routes

  api_id    = aws_apigatewayv2_api.student_api.id
  route_key = "${each.value.method} ${each.value.path}"

  target = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"
}

resource "aws_lambda_permission" "api_gateway" {
  for_each = local.api_routes

  statement_id  = "AllowAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.students[each.key].function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.student_api.execution_arn}/*/*"
}