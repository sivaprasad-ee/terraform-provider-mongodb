output "mongo_server_public_ip" {
  value = aws_instance.mongo_server.public_ip
}

output "mongo_vpc_ip" {
  value = aws_vpc.mongo_vpc.id
}

output "mongo__data_volume_attachment_id" {
  value = aws_volume_attachment.mongo-data-vol-attachment.id
}