variable "region" {
  type    = string
  default = "us-east-1"
}

provider "aws" {
  region = var.region
}
