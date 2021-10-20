variable "aws_region" {
  type    = string
  default = "us-east-1"
  description = "Region to deploy the Minecraft server in"
}

variable "domain_name" {
  type = string
  description = "Your domain to create a Hosted Zone for (for 'example.com' the server will be reachable under minecraft.example.com)"
}

variable "lambda_function_name" {
  type    = string
  default = "ondemand_minecraft_task_starter"
  description = "Override the lambda function's name"
}

variable "route53_log_retention_days" {
  type    = number
  default = 7
  description = "Time in days to keep the DNS logs"
}

variable "lambda_log_retention_days" {
  type    = number
  default = 7
  description = "Time in days to keep the function logs"
}

variable "sns_notification_email" {
  type = string
  description = "Mail address to send start/stop notifications to"
}

variable "startup_minutes" {
  type    = string
  default = "10"
  description = "Health check delay after starting the server"
}

variable "shutdown_minutes" {
  type    = string
  default = "20"
  description = "Delay after the last player left the server before it gets terminated"
}

variable "common_tags" {
  default = {
    For = "minecraft-ondemand"
  }
  description = "Tag all AWS Resources"
}