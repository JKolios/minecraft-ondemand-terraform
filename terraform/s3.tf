resource "aws_s3_bucket" "backup" {
  bucket = "backup-minecraft.${var.domain_name}"
  acl    = "private"

  tags = var.common_tags
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_iam_role" "backup" {
  name = "AWSDataSyncS3BucketAccess-backup-minecraft.${var.domain_name}"
  path = "/service-role/"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "datasync.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })
  managed_policy_arns = [aws_iam_policy.backup.arn]
  tags                = var.common_tags
}

resource "aws_iam_policy" "backup" {
  name = "AWSDataSyncS3BucketAccess-backup-minecraft.${var.domain_name}"
  path = "/service-role/"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3:::backup-minecraft.${var.domain_name}"
      },
      {
        "Action" : [
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListMultipartUploadParts",
          "s3:PutObjectTagging",
          "s3:GetObjectTagging",
          "s3:PutObject"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3:::backup-minecraft.${var.domain_name}/*"
      }
    ]
  })
  tags = var.common_tags
}
