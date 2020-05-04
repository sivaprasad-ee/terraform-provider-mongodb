data "aws_ami" "ami" {
  most_recent = true

  filter {
    name = "name"
    values = [
      var.ami_filter_name]
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
    Name = var.environment_tag
    Environment = var.environment_tag
  }
}

resource "aws_instance" "mongo_server" {
  ami                    = var.ami_id == "" ? data.aws_ami.ami.id : var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.subnet_public.id
  vpc_security_group_ids = [aws_security_group.sg_mongodb.id]
  key_name               = var.public_key

  root_block_device {
    //device_name = "/dev/sda1"
    volume_size = var.volume_size
    volume_type = "gp2"
    //delete_on_termination = false
  }

  tags = {
    Name = var.environment_tag
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
