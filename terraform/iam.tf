resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "minecraft_ondemand_fargate_task_role" {
  name = "ecs.task.minecraft-server"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_policy" "minecraft_ondemand_efs_access_policy" {
  name        = "minecraft_ondemand_efs_access_policy"
  path        = "/"
  description = "Allows Read Write access to the Minecraft server EFS"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:DescribeFileSystems"
        ],
        "Resource" : aws_efs_file_system.minecraft_ondemand_efs.arn,
        "Condition" : {
          "StringEquals" : {
            "elasticfilesystem:AccessPointArn" : aws_efs_access_point.minecraft_ondemand_efs_access_point.arn
          }
        }
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "minecraft_ondemand_efs_access_policy_attachment" {
  role       = aws_iam_role.minecraft_ondemand_fargate_task_role.name
  policy_arn = aws_iam_policy.minecraft_ondemand_efs_access_policy.arn
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "minecraft_ondemand_ecs_control_policy" {
  name        = "minecraft_ondemand_ecs_control_policy"
  path        = "/"
  description = "Allows the Minecraft server ECS task to understand which network interface is attached to it in order to properly update the DNS records"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecs:*"
        ],
        "Resource" : [
          aws_ecs_service.minecraft_ondemand_service.id,
          format("arn:aws:ecs:%s:%s:task/minecraft/*", var.aws_region, data.aws_caller_identity.current.account_id)
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeNetworkInterfaces"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "minecraft_ondemand_ecs_control_policy_attachment" {
  role       = aws_iam_role.minecraft_ondemand_fargate_task_role.name
  policy_arn = aws_iam_policy.minecraft_ondemand_ecs_control_policy.arn
}

resource "aws_iam_policy" "minecraft_ondemand_sns_publish_policy" {
  name        = "minecraft_ondemand_sns_publish_policy"
  path        = "/"
  description = "Allows the Minecraft server ECS task to send SNS notifications on a specific topic"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sns:Publish",
        "Resource" : aws_sns_topic.minecraft_ondemand_updates_topic.arn
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "minecraft_ondemand_sns_publish_policy_attachment" {
  role       = aws_iam_role.minecraft_ondemand_fargate_task_role.name
  policy_arn = aws_iam_policy.minecraft_ondemand_sns_publish_policy.arn
}

resource "aws_iam_policy" "minecraft_ondemand_route53_update_policy" {
  name        = "minecraft_ondemand_route53_update_policy"
  path        = "/"
  description = "Allows the Minecraft server ECS task to update DNS records on a hosted zone"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:GetHostedZone",
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : aws_route53_zone.minecraft_ondemand_route53_zone.arn
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ListHostedZones"
        ],
        "Resource" : "*"
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "minecraft_ondemand_route53_update_policy_attachment" {
  role       = aws_iam_role.minecraft_ondemand_fargate_task_role.name
  policy_arn = aws_iam_policy.minecraft_ondemand_route53_update_policy.arn
}

# Lambda Role

resource "aws_iam_role" "ondemand_minecraft_task_starter_lambda_role" {
  name = "ondemand_minecraft_task_starter_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "minecraft_ondemand_ecs_control_policy_attachment_lambda" {
  role       = aws_iam_role.ondemand_minecraft_task_starter_lambda_role.name
  policy_arn = aws_iam_policy.minecraft_ondemand_ecs_control_policy.arn
}

resource "aws_iam_role_policy_attachment" "minecraft_ondemand_lambda_cloudwatch_logging_policy_attachment" {
  role       = aws_iam_role.ondemand_minecraft_task_starter_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


# Cloudwatch Route53 logging policy document

data "aws_iam_policy_document" "route53-query-logging-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:log-group:/aws/route53/*"]

    principals {
      identifiers = ["route53.amazonaws.com"]
      type        = "Service"
    }
  }
}