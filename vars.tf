variable "aws_region" { default = "us-east-1"}
variable "vpc_cidr" { default = "10.0.0.0/16"}
variable "route53_hosted_zone_id" { default = "Z07224353LEFHPUMVIQRE"}
variable "domain_name" { default = "jkolios.xyz"}
variable "common_tags" { 
    default = {
        For = "minecraft-ondemand"
    }
}