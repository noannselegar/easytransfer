module "lambdas" {
  source   = "./modules/lambda"
  for_each = merge(local.api_lambdas, local.private_lambdas)

  function_name           = each.value.name
  description             = try(each.value.description, "N/A")
  runtime                 = try(each.value.runtime, "ruby3.3")
  handler                 = try(each.value.handler, "lambda.handler")
  memory_size             = try(each.value.memory_size, 128)
  env_variables           = try(each.value.env_variables, null)
  extra_policy_statements = try(each.value.extra_policy_statements, [])
}
