variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "domain_name" {
  type = string
}

variable "lambda_function_name" {
  type    = string
  default = "ondemand_minecraft_task_starter"
}

variable "route53_log_retention_days" {
  type    = number
  default = 7
}

variable "lambda_log_retention_days" {
  type    = number
  default = 7
}

variable "sns_notification_email" {
  type = string
}

variable "startup_minutes" {
  type    = string
  default = "10"
}

variable "shutdown_minutes" {
  type    = string
  default = "20"
}

variable "common_tags" {
  default = {
    For = "minecraft-ondemand"
  }
}