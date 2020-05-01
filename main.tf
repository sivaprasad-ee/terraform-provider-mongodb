resource "aws_vpc" "mongo_vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mongo_vpc.id
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id                  = aws_vpc.mongo_vpc.id
  cidr_block              = var.cidr_subnet
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.mongo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.rtb_public.id
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = [
    "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = [
    "hvm"]
  }

  filter {
    name = "root-device-type"
    values = [
    "ebs"]
  }
  owners = [
  "099720109477"]
  # Canonical
}

resource "aws_security_group" "sg_mongodb" {
  name   = "sg_mongodb"
  vpc_id = aws_vpc.mongo_vpc.id
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port = 27017
    to_port   = 27017
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
    description = "MongoDB access"
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Environment = var.environment_tag
  }
}

resource "aws_ebs_volume" "mongo-data-vol" {
  availability_zone = var.availability_zone
  type = "gp2"
  size = var.volume_size
  tags = {
    Name = "mongo-data-volume"
    Environment = var.environment_tag
  }
}

resource "aws_instance" "mongo_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_public.id
  vpc_security_group_ids = [aws_security_group.sg_mongodb.id]
  key_name               = var.public_key

  tags = {
    Environment = var.environment_tag
  }

  connection {
    host        = self.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.private_key
  }

  provisioner "file" {
    source      = "${path.module}/provisioning/wait-for-cloud-init.sh"
    destination = "/tmp/wait-for-cloud-init.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo ln -s /usr/bin/python3 /usr/bin/python",
      "chmod +x /tmp/wait-for-cloud-init.sh",
      "/tmp/wait-for-cloud-init.sh",
    ]
  }

}

resource "aws_volume_attachment" "mongo-data-vol-attachment" {
  device_name = "/dev/sdh"
  volume_id = aws_ebs_volume.mongo-data-vol.id
  instance_id = aws_instance.mongo_server.id

  skip_destroy = true

  connection {
    host = aws_instance.mongo_server.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.private_key
  }

  provisioner "file" {
    source      = "${path.module}/provisioning/mount-data-volume.sh"
    destination = "/tmp/mount-data-volume.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/mount-data-volume.sh",
      "/tmp/mount-data-volume.sh",
    ]
  }

  provisioner "ansible" {

    plays {
      playbook {
        file_path = "${path.module}/provisioning/playbook.yaml"
        roles_path = [
          "${path.module}/provisioning/roles/"
        ]
      }
      groups = ["db-mongodb"]
    }
  }
}