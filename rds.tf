# Define the database engine and version
variable "database_engine" {
  default = "mariadb"
}

variable "database_engine_version" {
  default = "10.5"
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

# Create a new DB security group
resource "aws_security_group" "db_security_group" {
  name_prefix = "csye6225-db-security-group"
  vpc_id      = aws_vpc.my_vpc.id
}

# Add an ingress rule to allow traffic from the application security group on port 3306
resource "aws_security_group_rule" "db_security_group_ingress" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_security_group.id
}

# Create the RDS instance
resource "aws_db_instance" "rds_instance" {
  identifier             = "csye6225"
  allocated_storage      = 5
  engine                 = var.database_engine
  engine_version         = var.database_engine_version
  instance_class         = "db.t3.micro"
  name                   = "csye6225"
  username               = "csye6225"
  password               = "Kanu1327"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name   = aws_db_parameter_group.db_parameter_group.name
  vpc_security_group_ids = [aws_security_group.app_security_group.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
}
