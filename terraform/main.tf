provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# ========================
# 1. VPC y Subnets públicas
# ========================
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "main-vpc" }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet-1" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet-2" }
}

# ========================
# 2. Internet Gateway + Rutas
# ========================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-route-table" }
}

resource "aws_route_table_association" "public_assoc" {
  for_each      = toset([aws_subnet.public_1.id, aws_subnet.public_2.id])
  subnet_id      = each.value
  route_table_id = aws_route_table.public_rt.id
}

# ========================
# 3. Security Group
# ========================
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP/HTTPS inbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ========================
# 4. Load Balancer + Target Group
# ========================
resource "aws_lb" "app_lb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# ========================
# 5. EC2 en subnet pública
# ========================
resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_1.id
  security_groups = [aws_security_group.alb_sg.id]

  tags = { Name = "AppServer" }
}

# ========================
# 6. RDS PostgreSQL (usando subnets públicas aquí)
# ========================
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

resource "aws_db_instance" "postgres" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15.2"
  instance_class         = "db.t3.micro"
  db_name                = "db-test-aws"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.alb_sg.id]
}

# ========================
# 7. Route53 + Alias al ALB
# ========================
resource "aws_route53_zone" "primary" {
  name = var.domain_name
}

resource "aws_route53_record" "alias" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}

# ========================
# 8. EFS
# ========================
resource "aws_efs_file_system" "efs" {
  creation_token = "my-efs"
  encrypted      = true
}

resource "aws_efs_mount_target" "efs_mount" {
  for_each       = toset([aws_subnet.public_1.id, aws_subnet.public_2.id])
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = each.value
  security_groups = [aws_security_group.alb_sg.id]
}

# ========================
# 9. Outputs
# ========================
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}
