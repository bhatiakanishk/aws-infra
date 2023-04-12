# Define the database engine and version

variable "database_engine" {
  default = "mariadb"
}
variable "database_engine_version" {
  default = "10.5"
}
variable "database_name" {
  default = "csye6225"
}
variable "database_username" {
  default = "csye6225"
}
variable "database_password" {
  default = "Kanu1327"
}

# Create a new DB parameter group

resource "aws_db_parameter_group" "db_parameter_group" {
  name        = "csye6225-db-parameter-group"
  family      = "mariadb${var.database_engine_version}"
  description = "Custom parameter group for CSYE6225 RDS instances"
}

# Create a new subnet group containing the private subnets where you want to deploy your RDS instance

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "csye6225-db-subnet-group"
  subnet_ids = aws_subnet.private_subnet.*.id
}

resource "aws_security_group" "database_security_group" {
  name_prefix = "csye6225-db-security-group"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the RDS instance

resource "aws_db_instance" "rds_instance" {
  identifier             = "csye6225"
  allocated_storage      = 5
  engine                 = var.database_engine
  engine_version         = var.database_engine_version
  instance_class         = "db.t3.micro"
  name                   = var.database_name
  username               = var.database_username
  password               = var.database_password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name
  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_encryption_key.arn
}