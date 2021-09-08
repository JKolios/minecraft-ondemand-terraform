resource "aws_cloudwatch_log_group" "aws_route53_hosted_zone_log_group" {
  name              = "/aws/route53/${aws_route53_zone.minecraft_ondemand_route53_zone.name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_resource_policy" "route53-query-logging-policy" {
  policy_document = data.aws_iam_policy_document.route53-query-logging-policy.json
  policy_name     = "route53-query-logging-policy"
}