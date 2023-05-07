output "alb_hostname" {
    value = aws_lb.alb.dns_name 
}