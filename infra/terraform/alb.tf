########################################
# Application Load Balancer
########################################
resource "aws_lb" "picus" {
  name               = "picus-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

########################################
# ECS için Target Group (FastAPI / Fargate)
########################################
resource "aws_lb_target_group" "picus_tg" {
  name        = "picus-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/picus/health"
    interval            = 20
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }

  tags = {
    Environment = var.environment
  }
}

########################################
# HTTP Listener (80) -> HTTPS'e redirect
########################################
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.picus.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

########################################
# HTTPS Listener (443)
# Default -> ECS Target Group
########################################
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.picus.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.picus_tg.arn
  }
}

########################################
# Lambda için ayrı Target Group
########################################
resource "aws_lb_target_group" "picus_delete_lambda" {
  name        = "picus-delete-lambda-tg"
  target_type = "lambda"

  # Çoklu header desteği (opsiyonel ama iyi)
  lambda_multi_value_headers_enabled = true
}

########################################
# Lambda'yı Target Group'a attach et
########################################
resource "aws_lb_target_group_attachment" "picus_delete_lambda_attachment" {
  target_group_arn = aws_lb_target_group.picus_delete_lambda.arn
  target_id        = "arn:aws:lambda:eu-central-1:358712298152:function:picus-delete-dev-deletePicusItem"

  depends_on = [
    aws_lambda_permission.allow_alb_invoke_delete
  ]
}

########################################
# HTTPS Listener Rule:
# DELETE /picus/* -> Lambda
########################################
resource "aws_lb_listener_rule" "picus_delete_https_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.picus_delete_lambda.arn
  }

  # /picus/* path'leri
  condition {
    path_pattern {
      values = ["/picus/*"]
    }
  }

  # Ve HTTP method DELETE olmalı
  condition {
    http_request_method {
      values = ["DELETE"]
    }
  }
}
