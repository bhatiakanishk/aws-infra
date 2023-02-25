variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance"
  default     = ""
}

resource "aws_instance" "my_ec2_instance" {
  count = 1
  # length(aws_subnet.public_subnet)
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.app_security_group.id]
  subnet_id                   = aws_subnet.public_subnet[0].id
  associate_public_ip_address = true
  key_name                    = "ec2"
  user_data                   = <<EOF
#!/bin/bash
cd /home/ec2-user/
npm install
sudo systemctl start mariadb
sudo mysql -u root
sudo mysql <<MYSQL_SCRIPT
CREATE DATABASE userDB;
CREATE DATABASE productDB;
drop user root@localhost;
FLUSH PRIVILEGES;
CREATE USER 'root'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON userDB.* TO 'root'@'localhost';
GRANT ALL PRIVILEGES ON productDB.* TO 'root'@'localhost';
MYSQL_SCRIPT

sudo systemctl restart mariadb
sudo pm2 kill
sudo pm2 flush
sudo pm2 start index.js
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
