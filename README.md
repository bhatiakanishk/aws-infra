# aws-infra
Infrastructure using terraform

## Prerequisites

## Github
A fork is made from the organization called kanishkbhatia/ aws-infra. The repository on the fork is then cloned locally using the 'git clone' command and using SSH.

### AWS
Install AWS on Linux by running the following command:

```
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Configure AWS by running the following command:

```
$ aws configure
```

### Terraform
Install Terraform on Linux by running the following command:

```
$ sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
```

Initialize the directory by running the following command:

```
$ terraform init
```

Create and execution plan by running the following command:

```
$ terraform plan
```

## Creating the infrastructure

Run the following command to select the AWS profile:

```
$ export AWS_PROFILE={PROFILE_NAME}
```

Create the infrastructure by running the following command:

```
$ terraform apply
```

## Destroying the infrastructure

Destroy the infrastructure by running the following command:

```
$ terraform destroy
```

## AWS VPC Console

Login to the AWS account and go to the VPC tab to check the infrastructure

ssh -i ~/.ssh/ec2 ec2-user@44.201.238.136