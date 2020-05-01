provider "aws" {
  region = "us-east-1"
  profile = "terraform-provisioner-ansible"
}

variable "env" {
  type = string
  description = "Environment type"
  default     = "terraform-mongo-test"
}

resource "aws_key_pair" "mongo_keypair" {
  key_name   = "mongo-publicKey"
  public_key = file("${path.module}/keys/id_rsa.pub")
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
  environment_tag   = var.env
}

output "mongo_server_public_ip" {
  value = module.mongodb.mongo_server_public_ip
}