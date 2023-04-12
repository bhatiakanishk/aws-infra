// AWS KMS Key for EBS Encryprtion
resource "aws_kms_key" "ebs_encryption_key" {
  description             = "Key for EBS Encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "kms:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "Enable EBS Volumes Encryption"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
      }
    ]
  })
}

// AWS KMS Key for RDS Encryprtion
resource "aws_kms_key" "rds_encryption_key" {
  description             = "Key for RDS Encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "kms:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "Enable RDS Encryption"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms: Encrypt*",
          "kms: Decrypt*",
          "kms: ReEncrypt*",
          "kms: GenerateDataKey*",
          "kms: Describe*"
        ]
        Resource = "*"
      }
    ]
  })
}