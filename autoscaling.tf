// Autoscaling Launch Configuration

resource "aws_launch_configuration" "asg_launch_config" {
    image_id                    = var.ami_id
    instance_type               = "t2.micro"
    key_name                    = "ec2-instance"
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_security_group.id]
    iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
    user_data                   = <<EOF
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
}

resource "aws_autoscaling_group" "asg" {
    name                 = "my-asg"
    launch_configuration = aws_launch_configuration.asg_launch_config.name
    min_size             = 1
    max_size             = 3
    desired_capacity     = 1
    vpc_zone_identifier  = [aws_subnet.public_subnet[0].id]

    tag {
        key                 = "ASG"
        value               = "my-asg"
        propagate_at_launch = true
    }
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

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
    alarm_name          = "cpu-high"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 120
    statistic           = "Average"
    threshold           = 5
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.asg.name
    }
    alarm_actions = [aws_autoscaling_policy.scale_up_policy.arn]
}

// Scale-down policy

resource "aws_autoscaling_policy" "scale_down_policy" {
    name                   = "scale-down-policy"
    policy_type            = "SimpleScaling"
    autoscaling_group_name = aws_autoscaling_group.asg.name
    adjustment_type        = "ChangeInCapacity"
    scaling_adjustment     = 1
    cooldown               = 60
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
    alarm_name          = "cpu-low"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 120
    statistic           = "Average"
    threshold           = 3
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.asg.name
    }
    alarm_actions = [aws_autoscaling_policy.scale_down_policy.arn]
}

resource "aws_autoscaling_attachment" "autoscalingattachment" {
    autoscaling_group_name  = aws_autoscaling_group.asg.id
    lb_target_group_arn     = aws_lb_target_group.my_target_group.arn
}