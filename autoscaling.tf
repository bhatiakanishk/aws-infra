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

// User data template file

data "template_file" "user_data" {
    template = <<EOF
#!/bin/bash
echo "SQLUSER="${var.sql_user}"" >> /home/ec2-user/webapp/.env
echo "SQLPASSWORD="${var.sql_password}"" >> /home/ec2-user/webapp/.env
echo "DATABASENAME=csye6225" >> /home/ec2-user/webapp/.env
echo "SQLHOSTNAME="${aws_db_instance.rds_instance.address}"" >> /home/ec2-user/webapp/.env
echo "BUCKETNAME="${aws_s3_bucket.private_bucket.bucket}"" >> /home/ec2-user/webapp/.env
echo "AWS_REGION="${var.region}"" >> /home/ec2-user/webapp/.env

cd /home/ec2-user/webapp/
sudo npm install -g pm2
sudo pm2 start index.js --name csye6225 --log ./csye6225.log
sudo pm2 startup systemd
sudo pm2 save
sudo pm2 list
EOF
}

// Autoscaling Launch Configuration

resource "aws_launch_template" "asg_launch_template" {
    image_id                    = var.ami_id
    instance_type               = "t2.micro"
    key_name                    = "ec2-instance"
    user_data                   = base64encode(data.template_file.user_data.rendered)
    iam_instance_profile {
        name = aws_iam_instance_profile.instance_profile_s3.name
    }
    network_interfaces {
        associate_public_ip_address = true
        security_groups             = [aws_security_group.app_security_group.id]
    }
}

// Autoscaling Group

resource "aws_autoscaling_group" "asg" {
    name                    = "my-asg"
    health_check_type       = "EC2"
    launch_template {
        id          = aws_launch_template.asg_launch_template.id
        version     = "$Latest"
    }
    min_size                = 1
    max_size                = 3
    desired_capacity        = 1
    vpc_zone_identifier     = [aws_subnet.public_subnet[0].id]

    tag {
        key                 = "ASG"
        value               = "my-asg"
        propagate_at_launch = true
    }
    lifecycle {
        create_before_destroy = true
    }
    target_group_arns = [aws_lb_target_group.my_target_group.arn]
    depends_on = [aws_lb_target_group.my_target_group]
}

// Scale-up policy

resource "aws_autoscaling_policy" "scale_up_policy" {
    name                   = "scale-up-policy"
    policy_type            = "SimpleScaling"
    autoscaling_group_name = aws_autoscaling_group.asg.name
    adjustment_type        = "ChangeInCapacity"
    scaling_adjustment     = 1
    cooldown               = 60
}

// Scale-down policy

resource "aws_autoscaling_policy" "scale_down_policy" {
    name                   = "scale-down-policy"
    policy_type            = "SimpleScaling"
    autoscaling_group_name = aws_autoscaling_group.asg.name
    adjustment_type        = "ChangeInCapacity"
    scaling_adjustment     = -1
    cooldown               = 60
}

// Autoscaling attachment

resource "aws_autoscaling_attachment" "autoscalingattachment" {
    autoscaling_group_name  = aws_autoscaling_group.asg.id
    lb_target_group_arn     = aws_lb_target_group.my_target_group.arn
}