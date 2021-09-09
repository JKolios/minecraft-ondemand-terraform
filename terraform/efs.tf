resource "aws_efs_file_system" "minecraft_ondemand_efs" {
  tags = var.common_tags
}

resource "aws_efs_access_point" "minecraft_ondemand_efs_access_point" {
  file_system_id = aws_efs_file_system.minecraft_ondemand_efs.id
  root_directory {
    path = "/minecraft"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = 755
    }
  }
  posix_user {
    uid = 1000
    gid = 1000
  }
  tags = var.common_tags
}

resource "aws_efs_mount_target" "minecraft_ondemand_efs_mount_target_a" {
  file_system_id  = aws_efs_file_system.minecraft_ondemand_efs.id
  subnet_id       = aws_default_subnet.default_az1.id
  security_groups = [aws_security_group.allow_minecraft_server_port.id]
}

resource "aws_efs_mount_target" "minecraft_ondemand_efs_mount_target_b" {
  file_system_id  = aws_efs_file_system.minecraft_ondemand_efs.id
  subnet_id       = aws_default_subnet.default_az2.id
  security_groups = [aws_security_group.allow_minecraft_server_port.id]
}

resource "aws_efs_mount_target" "minecraft_ondemand_efs_mount_target_c" {
  file_system_id  = aws_efs_file_system.minecraft_ondemand_efs.id
  subnet_id       = aws_default_subnet.default_az3.id
  security_groups = [aws_security_group.allow_minecraft_server_port.id]
}