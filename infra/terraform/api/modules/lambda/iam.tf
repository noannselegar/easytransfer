resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "policy" {
  policy = data.aws_iam_policy_document.policy_document.json
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.policy.arn
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.logs.arn,
      "${aws_cloudwatch_log_group.logs.arn}:*"
    ]
  }
  dynamic "statement" {
    for_each = { for statement in var.extra_policy_statements : statement.sid => statement }
    iterator = this

    content {
      sid       = this.value.sid
      effect    = this.value.effect
      resources = this.value.resources
      actions   = this.value.actions
    }
  }
}
