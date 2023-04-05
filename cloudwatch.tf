// Data Source for CloudWatch Agent

data "aws_iam_policy" "CloudWatchAgentServerPolicy" {
    arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

// Attach CloudWatch Agent Policy to the EC2 instance

resource "aws_iam_role_policy_attachment" "attachCloudWatchAgentPolicy" {
    role       = aws_iam_role.ec2_instance_role.name
    policy_arn = data.aws_iam_policy.CloudWatchAgentServerPolicy.arn
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
    alarm_name          = "cpu-low"
    comparison_operator = "LessThanOrEqualToThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 120
    statistic           = "Average"
    threshold           = 25
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.asg.name
    }
    alarm_actions = [aws_autoscaling_policy.scale_down_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
    alarm_name          = "cpu-high"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 2
    metric_name         = "CPUUtilization"
    namespace           = "AWS/EC2"
    period              = 120
    statistic           = "Average"
    threshold           = 40
    dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.asg.name
    }
    alarm_actions = [aws_autoscaling_policy.scale_up_policy.arn]
}