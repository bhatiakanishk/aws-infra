// Create private S3 bucket
resource "aws_s3_bucket" "private_bucket" {
  bucket = "private-bucket-${random_id.random.hex}"
  acl    = "private"

  lifecycle_rule {
    id      = "move-to-standard-ia"
    enabled = true
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

  // Configures server-side encryption with AES256 for the S3 bucket.
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  force_destroy = true
}

resource "random_id" "random" {
  byte_length = 4
}

// Block public access for S3
resource "aws_s3_bucket_public_access_block" "private_bucket_block" {
  bucket                  = aws_s3_bucket.private_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

// Create IAM Policy
resource "aws_iam_policy" "s3_access_policy" {
  name = "WebAppS3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.private_bucket.arn}",
          "${aws_s3_bucket.private_bucket.arn}/*"
        ]
      }
    ]
  })
}

// Create IAM Role
resource "aws_iam_role" "ec2_instance_role" {
  name = "EC2-CSYE6225"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  })
}

// Attache S3 access policy to the EC2 instance IAM role

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.ec2_instance_role.name
}

// Create instance profile for the EC2 instance with the assigned IAM role

resource "aws_iam_instance_profile" "instance_profile_s3" {
  name = "instance_profile_s3"
  role = aws_iam_role.ec2_instance_role.name
}