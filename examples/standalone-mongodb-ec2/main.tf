provider "aws" {
  region  = "us-east-1"
  profile = "terraform-provisioner-ansible"
}

module "mongodb" {
  source = "../../"

  cidr_vpc          = "10.1.0.0/16"
  cidr_subnet       = "10.1.0.0/24"
  availability_zone = "us-east-1a"
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
  value = "mongo mongodb://${module.mongodb.mongo_server_public_ip}:27017"
}
