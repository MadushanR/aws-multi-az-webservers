provider "aws" {
    region = var.aws_region
  }
  
  ####################
  # VPC
  ####################
  resource "aws_vpc" "main" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
      Name = "MyWebVPC"
    }
  }
  
  ####################
  # Subnets
  ####################
  resource "aws_subnet" "public_a" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = true
    tags = {
      Name = "PublicSubnet-A"
    }
  }
  
  resource "aws_subnet" "public_b" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.2.0/24"
    availability_zone       = "${var.aws_region}b"
    map_public_ip_on_launch = true
    tags = {
      Name = "PublicSubnet-B"
    }
  }
  
  ####################
  # Internet Gateway & Route Table
  ####################
  resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
      Name = "MyIGW"
    }
  }
  
  resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      Name = "PublicRouteTable"
    }
  }
  
  resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.public_a.id
    route_table_id = aws_route_table.public.id
  }
  
  resource "aws_route_table_association" "b" {
    subnet_id      = aws_subnet.public_b.id
    route_table_id = aws_route_table.public.id
  }
  
  ####################
  # Security Group
  ####################
  resource "aws_security_group" "web_sg" {
    name        = "WebSG"
    description = "Allow HTTP and SSH"
    vpc_id      = aws_vpc.main.id
  
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    tags = {
      Name = "WebSG"
    }
  }
  
  ####################
  # EC2 Instances
  ####################
  resource "aws_instance" "web_a" {
    ami                         = "ami-0c101f26f147fa7fd"
    instance_type               = "t2.micro"
    subnet_id                   = aws_subnet.public_a.id
    vpc_security_group_ids      = [aws_security_group.web_sg.id]
    associate_public_ip_address = true
    key_name                    = var.key_name
  
    user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd
                systemctl start httpd
                systemctl enable httpd
                echo "Hello from WebServer-A in AZ-a" > /var/www/html/index.html
                EOF
  
    tags = {
      Name = "WebServer-A"
    }
  }
  
  resource "aws_instance" "web_b" {
    ami                         = "ami-0c101f26f147fa7fd"
    instance_type               = "t2.micro"
    subnet_id                   = aws_subnet.public_b.id
    vpc_security_group_ids      = [aws_security_group.web_sg.id]
    associate_public_ip_address = true
    key_name                    = var.key_name
  
    user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd
                systemctl start httpd
                systemctl enable httpd
                echo "Hello from WebServer-B in AZ-b" > /var/www/html/index.html
                EOF
  
    tags = {
      Name = "WebServer-B"
    }
  }
  
  ####################
  # Target Group
  ####################
  resource "aws_lb_target_group" "tg" {
    name     = "web-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.main.id
    health_check {
      path                = "/"
      protocol            = "HTTP"
      matcher             = "200"
      interval            = 30
      timeout             = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }
  }
  
  resource "aws_lb_target_group_attachment" "a" {
    target_group_arn = aws_lb_target_group.tg.arn
    target_id        = aws_instance.web_a.id
    port             = 80
  }
  
  resource "aws_lb_target_group_attachment" "b" {
    target_group_arn = aws_lb_target_group.tg.arn
    target_id        = aws_instance.web_b.id
    port             = 80
  }
  
  ####################
  # Load Balancer
  ####################
  resource "aws_lb" "alb" {
    name               = "web-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.web_sg.id]
    subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  
    tags = {
      Name = "MyWebALB"
    }
  }
  
  resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.alb.arn
    port              = 80
    protocol          = "HTTP"
  
    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.tg.arn
    }
  }
  