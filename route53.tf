resource "aws_route53_zone" "minecraft_ondemand_route53_zone" {
  name = var.domain_name
}

resource "aws_cloudwatch_log_resource_policy" "minecraft_ondemand_route53_zone_query_log_policy" {
  policy_document = data.aws_iam_policy_document.route53-query-logging-policy.json
  policy_name     = "route53-query-logging-policy"
}

resource "aws_route53_query_log" "minecraft_ondemand_route53_zone_query_log_config" {
  depends_on = [aws_cloudwatch_log_resource_policy.route53-query-logging-policy]

  cloudwatch_log_group_arn = aws_cloudwatch_log_group.aws_route53_hosted_zone_log_group.arn
  zone_id                  = aws_route53_zone.minecraft_ondemand_route53_zone.zone_id
}

resource "aws_route53_record" "minecraft_ondemand_server_a_record" {
  zone_id = aws_route53_zone.minecraft_ondemand_route53_zone.zone_id
  name    = format("minecraft.%s",var.domain_name)
  type    = "A"
  ttl     = "30"
  records = ["1.1.1.1"]

  lifecycle {
    ignore_changes = [records]
  }
}