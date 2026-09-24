# Un nombre DNS estable para la demo.
# Sin esto, la IP pública de la tarea cambia cada vez que ECS la reemplaza,
# y el curl de la demo dejaría de funcionar justo después del fix.

resource "aws_security_group" "alb" {
  name        = "${var.name}-alb"
  description = "Entrada HTTP al balanceador"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.name}-alb" }
}

resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb.id]
  idle_timeout       = 30
}

resource "aws_lb_target_group" "app" {
  name        = var.service_name
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
    matcher             = "200"
  }

  deregistration_delay = 5
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

output "url" {
  description = "El nombre DNS estable del servicio. No cambia aunque se reemplace la tarea."
  value       = "http://${aws_lb.this.dns_name}/"
}
