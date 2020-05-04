variable "cidr_vpc" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "cidr_subnet" {
  type        = string
  description = "CIDR block for the subnet"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone to create subnet"
}

variable "instance_type" {
  type        = string
  description = "AWS EC2 instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  type        = string
  description = "AWS AMI Id"
  default     = ""
}

variable "ami_filter_name" {
  type        = string
  description = "AWS AMI Name filter value"
  default     = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
}

variable "volume_size" {
  type        = string
  description = "Size of the DB storage volume."
  default     = "100"
}

variable "environment_tag" {
  type        = string
  description = "Environment tag"
  default     = "Production"
}

variable "public_key" {
  type        = string
  description = "Public keypair name"
}

variable "private_key" {
  type        = string
  description = "Private key"
}
