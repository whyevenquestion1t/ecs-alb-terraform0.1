resource "aws_ecs_cluster" "production" {
  name = "terraform-ecs-cluster"
}

resource "aws_ecs_task_definition" "task_1" {
  family                   = "terraform"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsonencode([
    {
      name  = "nginx-terraform"
      image = "public.ecr.aws/nginx/nginx:perl"

      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "production" {
  name            = "demo-service-terraform"
  cluster         = aws_ecs_cluster.production.id
  task_definition = aws_ecs_task_definition.task_1.arn
  desired_count   = 3
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
    security_groups = [aws_security_group.ECS-sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "nginx-terraform"
    container_port   = 80
  }
}