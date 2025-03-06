resource "aws_apigatewayv2_api" "core_api" {
  name          = "easytransfer-core-api"
  description   = "Core API that serves as Easy Transfer's backend integrating with Lambda."
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://app.noannselegar.cloud"]
    allow_methods = ["GET", "POST", "PUT"]
  }
}

# Stage with Auto-Deploy (makes the API live)
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.core_api.id
  name        = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_rate_limit  = 100
    throttling_burst_limit = 100
  }
}

# API Integrations for Each Lambda
resource "aws_apigatewayv2_integration" "lambdas" {
  for_each = local.lambdas

  api_id                 = aws_apigatewayv2_api.core_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = module.lambdas[each.key].function_arn
  payload_format_version = "2.0"
}

# Routes for Each Lambda
resource "aws_apigatewayv2_route" "routes" {
  for_each = local.lambdas

  api_id    = aws_apigatewayv2_api.core_api.id
  route_key = each.value.route
  target    = "integrations/${aws_apigatewayv2_integration.lambdas[each.key].id}"
}

# Lambda Permissions for API Gateway to Invoke Functions
resource "aws_lambda_permission" "permissions" {
  for_each = local.lambdas

  action        = "lambda:InvokeFunction"
  function_name = module.lambdas[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.core_api.id}/*/${replace(replace(each.value.route, " ", ""), "/{\\w+}/", "*")}*"
}
