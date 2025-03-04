module "lambdas" {
  source   = "./modules/lambda"
	for_each = local.lambdas

	function_name           = each.value.name
	description             = try(each.value.description, "N/A")
	runtime                 = try(each.value.runtime, "ruby3.3")
	handler   							= try(each.value.handler, "lambda.handler")
	memory_size  					  = try(each.value.memory_size, 128)
	extra_policy_statements = try(each.value.extra_policy_statements, [])
}
