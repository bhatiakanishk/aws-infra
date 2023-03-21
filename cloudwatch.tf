// Data Source for CloudWatch Agent

data "aws_iam_policy" "CloudWatchAgentServerPolicy" {
    arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

// Attach CloudWatch Agent Policy to the EC2 instance

resource "aws_iam_role_policy_attachment" "attachCloudWatchAgentPolicy" {
    role       = aws_iam_role.ec2_instance_role.name
    policy_arn = data.aws_iam_policy.CloudWatchAgentServerPolicy.arn
}