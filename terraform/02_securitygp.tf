resource "aws_security_group" "ALB-sg" {
  name        = "ALB-sg"
  description = "Inbound http traffic from anywhere"
  vpc_id      = aws_vpc.production_vpc.id
  tags = {
    Name = "tf-test-sg-alb"
  }

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

resource "aws_security_group" "ECS-sg" {
  name        = "ECS-sg"
  description = "containers-for-alb"
  vpc_id      = aws_vpc.production_vpc.id
  tags = {
    Name = "tf-test-sg-ecs"
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ALB-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}