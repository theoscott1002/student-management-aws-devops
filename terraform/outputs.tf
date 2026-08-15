output "dynamodb_table_name" {
  value = aws_dynamodb_table.students.name
}

output "aws_region" {
  value = var.aws_region
}

output "api_url" {
  value = aws_apigatewayv2_stage.dev.invoke_url
}

output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

output "s3_bucket_name" {
  value = aws_s3_bucket.frontend.bucket
}