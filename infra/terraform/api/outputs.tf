output "http_api_id" {
  description = "HTTP API ID"
  value       = aws_apigatewayv2_api.core_api.id
}

output "http_api_endpoint" {
  description = "Invoke URL for the default stage"
  value       = "https://${aws_apigatewayv2_api.core_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com"
}

