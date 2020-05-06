provider "aws" {
  region  = "us-east-1"
  profile = "terraform-provisioner-ansible"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all_subnets" {
  vpc_id = data.aws_vpc.default.id
}

module "mongodb" {
  source = "../../"
  vpc_id = data.aws_vpc.default.id
  subnet_id = tolist(data.aws_subnet_ids.all_subnets.ids)[0]
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
