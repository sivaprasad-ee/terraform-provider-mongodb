# Terraform MongoDB Provider for AWS

This module provision MongoDB server on AWS EC2 instance using Ansible provisioner.
This module uses [undergreen.mongodb](https://galaxy.ansible.com/undergreen/mongodb) Ansible role to provision mongodb.
So, you can use any of the [platforms supported by **undergreen.mongodb**](https://github.com/UnderGreen/ansible-role-mongodb/blob/master/README.md) role while selecting the AMI ID.

## Dependencies

### 1. Ansible provisioner
This module depends on the Ansible provisioner. 
See the [installation instructions](https://github.com/radekg/terraform-provisioner-ansible#installation).

Download a [Prebuilt release available on GitHub](https://github.com/radekg/terraform-provisioner-ansible/releases),
rename it to **terraform-provisioner-ansible** and place it in **~/.terraform.d/plugins** directory.

### 2. SSH Keys
User needs to provide SSH keys for the **terraform-provider-mongodb** module to perform remote provisioning.

You can generate SSH keys using the following command:

`$ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"`

For more info on generating SSH keys refer https://help.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent

## Example:

### standalone-mongodb-ec2

```hcl-terraform
provider "aws" {
  region = "us-east-1"
  profile = "terraform-provisioner-ansible"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all_subnets" {
  vpc_id = data.aws_vpc.default.id
}

module "mongodb" {
  //public use
  //source          = "https://github.com/everest-engineering/terraform-provider-mongodb"
  
  source            = "../../"
  vpc_id            = data.aws_vpc.default.id
  subnet_id         = tolist(data.aws_subnet_ids.all_subnets.ids)[0]
  instance_type     = "t2.micro"
  ami_filter_name   = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
  volume_size       = "8"
  private_key       = file("~/.ssh/id_rsa")
  public_key        = file("~/.ssh/id_rsa.pub")
  environment_tag   = "terraform-mongo-test"
}

output "mongo_server_public_ip" {
  value = module.mongodb.mongo_server_public_ip
}

output "mongo_connect_url" {
  value = module.mongodb.mongo_connect_url
}
```

**Configure AWS Credentials as environment variables:**

```shell script
export AWS_ACCESS_KEY_ID="ACCESS_KEY_HERE"
export AWS_SECRET_ACCESS_KEY="SECRET_ACCESS_KEY_HERE"
export AWS_DEFAULT_REGION="REGION_HERE"
```

**Provision MongoDB on AWS:**

```shell script
cd terraform-provider-mongodb/examples/standalone-mongodb-ec2
terraform init
terraform plan
terraform apply
```

**Destroy the provisioned infrastructure:**

```shell script
cd terraform-provider-mongodb/examples/standalone-mongodb-ec2
terraform destroy
```
