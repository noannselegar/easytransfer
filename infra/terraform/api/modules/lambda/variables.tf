variable "function_name" {
  description = "Name for the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = "N/A"
}

variable "runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "ruby3.3"
}

variable "handler" {
  description = "Handler for the Lambda function"
  type        = string
  default     = "lambda.handler"
}

variable "memory_size" {
  description = "Memory size for the Lambda function"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout in seconds for the Lambda function."
  type        = number
  default     = 5
}

variable "env_variables" {
  description = "Environment variables map."
  type        = map(string)
  default     = null
}

variable "extra_policy_statements" {
  description = "Additional IAM policy statements for the Lambda"
  type = list(object({
    sid       = string
    effect    = optional(string, "Allow")
    actions   = list(string)
    resources = optional(list(string), ["*"])
  }))
  default = []
}
