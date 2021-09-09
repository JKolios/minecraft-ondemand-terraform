resource "aws_ecs_cluster" "minecraft_ondemand_cluster" {
  name               = "minecraft"
  capacity_providers = ["FARGATE_SPOT"]

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.common_tags
}

resource "aws_ecs_task_definition" "minecraft_ondemand_task" {
  family             = "minecraft-server"
  task_role_arn      = aws_iam_role.minecraft_ondemand_fargate_task_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  memory = 2048
  cpu    = 1024

  container_definitions = jsonencode([
    {
      name      = "minecraft-server"
      image     = "itzg/minecraft-server"
      essential = false
      portMappings = [
        {
          containerPort = 25565
          hostPort      = 25565
        }
      ]
      environment = [
        {
          name  = "EULA"
          value = "TRUE"
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "data"
          containerPath = "/data"
        }
      ]
    },
    {
      name      = "minecraft-ecsfargate-watchdog"
      image     = "doctorray/minecraft-ecsfargate-watchdog"
      essential = true
      environment = [
        {
          name  = "CLUSTER"
          value = aws_ecs_cluster.minecraft_ondemand_cluster.name
        },
        {
          name  = "SERVICE"
          value = "minecraft-server"
        },
        {
          name  = "DNSZONE"
          value = aws_route53_zone.minecraft_ondemand_route53_zone.id
        },
        {
          name  = "SERVERNAME"
          value = format("minecraft.%s", var.domain_name)
        },
        {
          name  = "SNSTOPIC"
          value = aws_sns_topic.minecraft_ondemand_updates_topic.arn
        },
        {
          name  = "STARTUPMIN"
          value = var.startup_minutes
        },
        {
          name  = "SHUTDOWNMIN"
          value = var.shutdown_minutes
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "data"
          containerPath = "/data"
        }
      ]
    }
  ])

  volume {
    name = "data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.minecraft_ondemand_efs.id
      transit_encryption = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.minecraft_ondemand_efs_access_point.id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "minecraft_ondemand_service" {
  name            = "minecraft-server"
  cluster         = aws_ecs_cluster.minecraft_ondemand_cluster.id
  task_definition = aws_ecs_task_definition.minecraft_ondemand_task.arn
  desired_count   = 0
  #   iam_role        = aws_iam_role.minecraft_ondemand_fargate_task_role.arn
  depends_on = [aws_iam_policy.minecraft_ondemand_efs_access_policy]

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets          = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id, aws_default_subnet.default_az3.id]
    security_groups  = [aws_security_group.allow_minecraft_server_port.id]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}