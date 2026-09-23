# Servicio "de produccion" de la demo.
# La app arranca solo si APP_MESSAGE existe: asi el crash loop se inyecta
# quitando una variable de entorno, que es la falla #1 real en ECS.

resource "aws_cloudwatch_log_group" "app" {
  name              = "/dataplat/prod/${var.service_name}"
  retention_in_days = 1
}

resource "aws_ecs_cluster" "this" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = "disabled" # cuesta y no aporta a la historia
  }
}

resource "aws_iam_role" "task_execution" {
  name = "${var.name}-${var.service_name}-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

locals {
  # Sin APP_MESSAGE el contenedor sale con codigo 1 antes de levantar el server.
  app_command = [
    "/bin/sh", "-c",
    "if [ -z \"$APP_MESSAGE\" ]; then echo 'FATAL: APP_MESSAGE no esta definida' >&2; exit 1; fi; echo \"ingest-api v$APP_VERSION | $APP_MESSAGE\" > /tmp/index.html; echo \"listening on 8080, version $APP_VERSION\"; cd /tmp; exec httpd -f -p 8080"
  ]

  app_environment = concat(
    [{ name = "APP_VERSION", value = var.app_version }],
    var.app_message == "" ? [] : [{ name = "APP_MESSAGE", value = var.app_message }]
  )
}

resource "aws_ecs_task_definition" "app" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task_execution.arn

  container_definitions = jsonencode([{
    name        = var.service_name
    image       = "public.ecr.aws/docker/library/busybox:1.36"
    essential   = true
    command     = local.app_command
    environment = local.app_environment

    portMappings = [{
      containerPort = 8080
      protocol      = "tcp"
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.app.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

resource "aws_ecs_service" "app" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = true
  }

  deployment_circuit_breaker {
    enable   = false # queremos ver el crash loop, no que ECS lo tape
    rollback = false
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}
