# El secreto vive acá, nunca en el repositorio ni en el prompt del agente.
# ECS lo inyecta en el contenedor al arrancar: el valor no aparece en el task
# definition, solo la referencia al ARN.

resource "random_password" "api_token" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "app" {
  name                    = "${var.name}/${var.service_name}/api-token"
  description             = "Token de la API de ingesta. Inyectado por ECS en tiempo de ejecucion."
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = aws_secretsmanager_secret.app.id
  secret_string = random_password.api_token.result
}

# Solo el rol de ejecucion de la tarea puede leerlo. El rol del agente no.
resource "aws_iam_role_policy" "task_execution_secrets" {
  name = "leer-secreto"
  role = aws_iam_role.task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_secretsmanager_secret.app.arn
    }]
  })
}

output "secreto" {
  description = "El ARN de la referencia. El valor nunca se imprime."
  value       = aws_secretsmanager_secret.app.name
}
