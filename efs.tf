resource "aws_efs_file_system" "minecraft_ondemand_efs" {
  tags = var.common_tags
}

resource "aws_efs_access_point" "minecraft_ondemand_efs_access_point" {
  file_system_id = aws_efs_file_system.minecraft_ondemand_efs.id
  root_directory {
    path = "/minecraft"
    creation_info {
        owner_uid = 1000
        owner_gid = 1000
        permissions = 755
    }
  }
  posix_user {
        uid = 1000
        gid = 1000
    }
  tags = var.common_tags
}