variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance"
  default     = ""
}

variable "sql_user" {
  default = "csye6225"
}

variable "sql_password" {
  default = "Kanu1327"
}

variable "aws_accesskey" {
  default = "AKIAQCT5GEIRYB24L5KC"
}

variable "aws_secretkey" {
  default = "gViouWuRm8vmk4CR6AQ6F2ZInQJAWOdNGbQKdYB0"
}

resource "aws_instance" "my_ec2_instance" {
  count                       = 1
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.app_security_group.id]
  subnet_id                   = aws_subnet.public_subnet[0].id
  associate_public_ip_address = true
  key_name                    = "ec2"
  user_data                   = <<EOF
#!/bin/bash
echo "SQLUSER="${var.sql_user}"" >> /home/ec2-user/webapp/.env
echo "SQLPASSWORD="${var.sql_password}"" >> /home/ec2-user/webapp/.env
echo "DATABASENAME=csye6225" >> /home/ec2-user/webapp/.env
echo "SQLHOSTNAME="${aws_db_instance.rds_instance.address}"" >> /home/ec2-user/webapp/.env
echo "BUCKETNAME="${aws_s3_bucket.private_bucket.bucket}"" >> /home/ec2-user/webapp/.env
echo "AWS_ACCESS_KEY_ID="${var.aws_accesskey}"" >> /home/ec2-user/webapp/.env
echo "AWS_SECRET_ACCESS_KEY="${var.aws_secretkey}"" >> /home/ec2-user/webapp/.env
echo "AWS_REGION="${var.region}"" >> /home/ec2-user/webapp/.env

cd /home/ec2-user/webapp/
sudo npm install -g pm2
sudo pm2 start index.js --name csye6225 --log ./csye6225.log
sudo pm2 startup systemd
sudo pm2 save
sudo pm2 list
EOF

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 50
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }
  credit_specification {
    cpu_credits = "standard"
  }
  disable_api_termination = true
  tags = {
    Name = "my-ec2-instance-${count.index}"
  }
}
