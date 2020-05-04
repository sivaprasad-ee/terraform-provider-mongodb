output "mongo_server_public_ip" {
  value = aws_instance.mongo_server.public_ip
}

output "mongo_vpc_ip" {
  value = aws_vpc.mongo_vpc.id
}
