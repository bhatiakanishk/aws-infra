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

## Variables file

Create a variable.tfvars file and add the following code to it:

```
region = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
ami_id = "ami-0123456789"
```

Change the values as per the requirement

## Creating the infrastructure

Run the following command to select the AWS profile:

```
$ export AWS_PROFILE={PROFILE_NAME}
```

Create the infrastructure by running the following command:

```
$ terraform apply --var-file="variable.tfvars" 
```

## Destroying the infrastructure

Destroy the infrastructure by running the following command:

```
$ terraform destroy
```

## AWS VPC Console

Login to the AWS account and go to the VPC tab to check the infrastructure

## AWS Instances Console

Copy the Public IPv4 DNS to check the API requests

## Postman

Postman needs to be installed for testing the API calls
```
http://{Public IPv4 DNS}:8080/{requiredRequest}
```

Depending on the type of API call, change the HTTP requests

Use JSON format in the body of Postman

Sample to add new user:
```
{
    "username": "login@gmail.com",
    "first_name": "Kanishk",
    "last_name": "Bhatia",
    "password": "12345"
}

Sample to add new product:

{
    "name": "Galaxy S22",
    "description": "Smartphone",
    "sku": "1",
    "manufacturer": "Samsung",
    "quantity": 50
}
```