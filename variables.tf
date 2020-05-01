variable "cidr_vpc" {
  type = string
  description = "CIDR block for the VPC"
}

variable "cidr_subnet" {
  type = string
  description = "CIDR block for the subnet"
}

variable "availability_zone" {
  type = string
  description = "Availability zone to create subnet"
}

variable "instance_type" {
  type = string
  description = "AWS EC2 instance type"
  default     = "t2.micro"
}

variable "volume_size" {
  type        = string
  description = "Size of the DB storage volume."
  default     = "100"
}

variable "environment_tag" {
  type = string
  description = "Environment tag"
  default     = "Production"
}
/*
variable "security_groups" {
  type        = list(string)
  description = "List of security group names."
  default     = []
}*/

variable "public_key" {
  type = string
  description = "Public keypair name"
}

variable "private_key" {
  type = string
  description = "Private key"
}
