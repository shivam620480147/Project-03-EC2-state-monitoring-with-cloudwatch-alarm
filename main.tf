
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

# Find the existing default VPC
data "aws_vpc" "default" {
  default = true
}

# Find the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Security group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "shivam-project3-ec2-sg"
  description = "Security group for Project 3 EC2"
  vpc_id      = data.aws_vpc.default.id

  # No inbound access is required for this monitoring exercise

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Shivam-Project3-EC2-SG"
  }
}

# Create EC2 instance
resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  tags = {
    Name = "Shivam-Project3-EC2"
  }
}

# CloudWatch CPU utilization alarm
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "Shivam-Project3-High-CPU"
  alarm_description   = "Alarm when EC2 CPU utilization exceeds 70%"
  comparison_operator = "GreaterThanThreshold"

  evaluation_periods  = 1
  datapoints_to_alarm = 1
  period              = 300
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  threshold           = 70

  treat_missing_data = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.web.id
  }

  tags = {
    Name = "Shivam-Project3-CPU-Alarm"
  }
}
