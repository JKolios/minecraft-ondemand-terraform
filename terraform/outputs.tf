output "hosted_zone_nameservers" {
  value       = aws_route53_zone.minecraft_ondemand_route53_zone.name_servers
  description = "The Hosted Zone's NS records. Use this to delegate the zone from your parent zone."
}