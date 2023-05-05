# Application Load Balancer 
resource "aws_lb" "alb" {
  name               = "alb-for-ecs-test"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB-sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

}

# Target Group
resource "aws_lb_target_group" "tg" {
  name        = "target-group-terraform"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.production_vpc.id
  target_type = "ip"
  health_check {
    path    = "/"
    matcher = "200"
  }
}

# Listener rule (will route traffic ALB -> Target Group)
resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  depends_on        = [aws_lb_target_group.tg]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn

  }
}