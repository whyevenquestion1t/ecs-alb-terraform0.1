resource "aws_ecs_cluster" "production" {
  name = "ecs-demo"
}

resource "aws_ecs_task_definition" "task_1" {
  family                   = "ecs-demo"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions = jsonencode([
    {
      name  = "web"
      image = "registry.gitlab.com/shoysoronovr/eco-demo/master:latest"

      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "production" {
  name            = "ecs-demo"
  cluster         = aws_ecs_cluster.production.id
  task_definition = aws_ecs_task_definition.task_1.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]
    security_groups = [aws_security_group.ECS-sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "web"
    container_port   = 5000
  }
}