# ========================
# Latest Amazon Linux 2023 AMI with Kernel 6.1,it is selected because AL2 will be Out of support from 2025,Dec.
# ========================
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ========================
# Launch Template
# ========================
resource "aws_launch_template" "lt" {
  name_prefix   = "zantac-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  user_data = base64encode(file(var.user_data_file_path))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.sg_id]
  }
}

# ========================
# Auto Scaling Group with Target Group Registration
# ========================
resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.public_subnets

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  tag {
    key                 = "Name"
    value               = "ZantacWeb"
    propagate_at_launch = true
  }
}

# ========================
# Application Load Balancer
# ========================
resource "aws_lb" "alb" {
  name               = "zantac-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = var.public_subnets
}

# ========================
# Target Group with Health Check
# ========================
resource "aws_lb_target_group" "tg" {
  name     = "zantac-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ========================
# Listener
# ========================
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ========================
# Input Variables
# ========================
variable "vpc_id" {}
variable "public_subnets" {}
variable "sg_id" {}
variable "key_name" {}
variable "user_data_file_path" {}

