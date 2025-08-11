output "alb_dns" {
  value = aws_lb.app_lb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "app_server_public_ip" {
  value = aws_instance.app_server.public_ip
}
