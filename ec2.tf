variable "ami_id" {
  description = "The ID of the AMI to use for the EC2 instance"
  default     = "ami-0fb8984d13804b809"
}

resource "aws_instance" "my_ec2_instance" {
  count                       = length(aws_subnet.public_subnet)
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.app_security_group.id]
  subnet_id                   = aws_subnet.public_subnet[count.index].id
  associate_public_ip_address = true
  key_name                    = "ec2"
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
