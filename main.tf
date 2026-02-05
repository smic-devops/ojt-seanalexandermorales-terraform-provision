# Security Groups of Application Load Balancer and EC2 Instance
resource "aws_security_group" "alb_sg" {
  name   = "itss-ojt-Morales-alb-sg"
  vpc_id = var.vpc_id

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

  tags = {
    Environment    = "Sandbox"
    Resource_Types = "Instances Volumes Network_Interfaces"
  }
}

resource "aws_security_group" "ec2_sg" {
  name   = "itss-ojt-Morales-ec2-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment    = "Sandbox"
    Resource_Types = "Instances Volumes Network_Interfaces"
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "alb" {
  name               = "itss-ojt-Morales-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Environment = "Sandbox"
  }
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name     = "itss-ojt-Morales-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Environment    = "Sandbox"
    Resource_Types = "Instances Volumes Network_Interfaces"
  }
}

# Application Load Balancer Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }

  tags = {
    Environment    = "Sandbox"
    Resource_Types = "Instances Volumes Network_Interfaces"
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami             = "ami-039a8ebebdd2a1def"  
  instance_type   = var.instance_type
  subnet_id       = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name            = "itss-ojt-Morales-ec2-v2"
    Environment     = "Sandbox"
    backup          = "no"
    Schedule        = "running"
    Patch           = "No"
    Resource_Types  = "Instances Volumes Network_Interfaces"
  }
}

# Register EC2 with the target group
resource "aws_lb_target_group_attachment" "attachment" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.web.id
  port             = 80
}