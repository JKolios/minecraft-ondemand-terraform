resource "aws_cloudwatch_log_group" "aws_route53_hosted_zone_log_group" {
  name              = "/aws/route53/${aws_route53_zone.minecraft_ondemand_route53_zone.name}"
  retention_in_days = var.route53_log_retention_days
}

resource "aws_cloudwatch_log_resource_policy" "route53_query_logging_policy" {
  policy_document = data.aws_iam_policy_document.route53-query-logging-policy.json
  policy_name     = "route53-query-logging-policy"
}

resource "aws_cloudwatch_log_subscription_filter" "minecraft_ondemand_route53_query_log_filter" {
  depends_on      = [aws_lambda_permission.allow_cloudwatch]
  name            = "minecraft_ondemand"
  log_group_name  = aws_cloudwatch_log_group.aws_route53_hosted_zone_log_group.name
  filter_pattern  = format("minecraft.%s", var.domain_name)
  destination_arn = aws_lambda_function.ondemand_minecraft_task_starter_lambda.arn
}

resource "aws_cloudwatch_log_group" "lambda_function_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = var.lambda_log_retention_days
}