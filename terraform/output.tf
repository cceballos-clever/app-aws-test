output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "alb_dns" {
  value = aws_lb.app_lb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}
