data "aws_ami" "latest_ami" {
  most_recent = true
  owners      = ["005631255075", "936367200970"]
}