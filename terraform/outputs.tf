output "hosted_zone_nameservers" {
  value = aws_route53_zone.minecraft_ondemand_route53_zone.name_servers
}