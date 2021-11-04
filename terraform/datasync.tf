resource "aws_datasync_location_s3" "backup" {
  s3_bucket_arn = aws_s3_bucket.backup.arn
  subdirectory  = "/minecraft"

  s3_config {
    bucket_access_role_arn = aws_iam_role.backup.arn
  }

  tags = var.common_tags
}

resource "aws_datasync_location_efs" "minecraft_ondemand_efs" {
  efs_file_system_arn = aws_efs_file_system.minecraft_ondemand_efs.arn
  subdirectory        = "/minecraft"
  ec2_config {
    subnet_arn          = aws_default_subnet.default_az1.arn
    security_group_arns = [aws_security_group.allow_minecraft_server_port.arn]
  }

  tags = var.common_tags
}

resource "aws_datasync_task" "backup-create" {
  destination_location_arn = aws_datasync_location_s3.backup.arn
  name                     = "backup-create"
  source_location_arn      = aws_datasync_location_efs.minecraft_ondemand_efs.arn

  schedule {
    schedule_expression = "cron(0 8 * * ? *)"
  }
  options {
    atime                  = "BEST_EFFORT"
    bytes_per_second       = -1
    gid                    = "INT_VALUE"
    log_level              = "OFF"
    mtime                  = "PRESERVE"
    overwrite_mode         = "ALWAYS"
    posix_permissions      = "PRESERVE"
    preserve_deleted_files = "PRESERVE"
    preserve_devices       = "NONE"
    task_queueing          = "ENABLED"
    transfer_mode          = "CHANGED"
    uid                    = "INT_VALUE"
    verify_mode            = "ONLY_FILES_TRANSFERRED"
  }
  tags = var.common_tags
}

resource "aws_datasync_task" "backup-restore" {
  destination_location_arn = aws_datasync_location_efs.minecraft_ondemand_efs.arn
  name                     = "backup-restore"
  source_location_arn      = aws_datasync_location_s3.backup.arn
  options {
    atime                  = "BEST_EFFORT"
    bytes_per_second       = -1
    gid                    = "NONE"
    log_level              = "OFF"
    mtime                  = "PRESERVE"
    overwrite_mode         = "ALWAYS"
    posix_permissions      = "NONE"
    preserve_deleted_files = "REMOVE"
    preserve_devices       = "NONE"
    task_queueing          = "ENABLED"
    transfer_mode          = "CHANGED"
    uid                    = "NONE"
    verify_mode            = "ONLY_FILES_TRANSFERRED"
  }
  tags = var.common_tags
}
