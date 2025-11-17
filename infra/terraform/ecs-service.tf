resource "aws_ecs_service" "picus_service" {
  name            = "picus-service"
  cluster         = aws_ecs_cluster.picus.id
  task_definition = aws_ecs_task_definition.picus_api.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.picus_tg.arn
    container_name   = "picus-api"
    container_port   = var.container_port
  }

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  depends_on = [
    aws_lb_listener.http
  ]
}
