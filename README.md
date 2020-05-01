# Terraform MongoDB Provider for AWS

This module provision MongoDB on AWS EC2 instance using Ansible provisioner.
The module creates a new **vpc, internet_gateway, subnet, route_table, route_table_association, 
security_group, ebs_volume** and **Ubuntu based EC2 instance**. 

## Dependencies
This module depends on the Ansible provisioner. 
See their [installation instructions](https://github.com/radekg/terraform-provisioner-ansible#installation).

Download a [Prebuilt release available on GitHub](https://github.com/radekg/terraform-provisioner-ansible/releases),
rename it to **terraform-provisioner-ansible** and place it in **~/.terraform.d/plugins** directory.

## Example:

### standalone-mongodb-ec2

```hcl-terraform
provider "aws" {
  region = "us-east-1"
  profile = "terraform-provisioner-ansible"
}

module "mongodb" {
  source = "../../"

  cidr_vpc          = "10.1.0.0/16"
  cidr_subnet       = "10.1.0.0/24"
  availability_zone = "us-east-1a"
  instance_type     = "t2.micro"
  volume_size       = "10"
  private_key       = file("${path.module}/keys/id_rsa")
  public_key        = aws_key_pair.mongo_keypair.key_name
  environment_tag   = "production"
}

resource "aws_key_pair" "mongo_keypair" {
  key_name   = "mongo-publicKey"
  public_key = file("${path.module}/keys/id_rsa.pub")
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
