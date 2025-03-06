resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = var.description
  runtime       = var.runtime
  handler       = var.handler
  memory_size   = var.memory_size
  role          = aws_iam_role.lambda_role.arn
  filename      = "${path.module}/lambda.zip"

  dynamic "environment" {
    for_each = var.env_variables != null ? ["enabled"] : []

    content {
      variables = var.env_variables
    }
  }
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 7
}
