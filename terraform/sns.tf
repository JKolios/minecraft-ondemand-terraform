resource "aws_sns_topic" "minecraft_ondemand_updates_topic" {
  name = "minecraft-server-updates-topic"
}

resource "aws_sns_topic_subscription" "minecraft_ondemand_updates_topic_email_subscription" {
  topic_arn = aws_sns_topic.minecraft_ondemand_updates_topic.arn
  protocol  = "email"
  endpoint  = var.sns_notification_email
}