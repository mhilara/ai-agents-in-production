# Dos identidades, dos niveles de permiso. Este es el guardarrail de la charla:
# el agente vive en demo-ro y no puede escribir aunque quiera.

data "aws_caller_identity" "current" {}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  demo_prefix = var.name
}

# --- Guardarrail comun: nadie de la demo toca IAM, billing ni la base de produccion
resource "aws_iam_policy" "boundary" {
  name        = "${var.name}-boundary"
  description = "Limite duro para las identidades de la demo"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "PermitirSoloLoDeLaDemo"
        Effect   = "Allow"
        Action   = ["ecs:*", "logs:*", "cloudwatch:*", "ec2:*", "s3:*", "budgets:*", "iam:PassRole", "iam:Get*", "iam:List*", "sts:*"]
        Resource = "*"
      },
      {
        Sid      = "NadaDeProduccion"
        Effect   = "Deny"
        Action   = ["rds:*", "organizations:*", "account:*", "aws-portal:*", "ce:*"]
        Resource = "*"
      },
      {
        Sid    = "NadaDeIamFueraDeLaDemo"
        Effect = "Deny"
        Action = ["iam:Create*", "iam:Delete*", "iam:Put*", "iam:Attach*", "iam:Detach*", "iam:Update*"]
        NotResource = [
          "arn:aws:iam::${local.account_id}:role/${local.demo_prefix}-*",
          "arn:aws:iam::${local.account_id}:policy/${local.demo_prefix}-*"
        ]
      }
    ]
  })
}

# --- Rol del agente: SOLO LECTURA
resource "aws_iam_role" "agent_readonly" {
  name                 = "${var.name}-agent-readonly"
  permissions_boundary = aws_iam_policy.boundary.arn
  max_session_duration = 14400

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${local.account_id}:root" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "agent_readonly" {
  name = "lectura"
  role = aws_iam_role.agent_readonly.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LeerTodoLoNecesarioParaDiagnosticar"
        Effect = "Allow"
        Action = [
          "ecs:Describe*", "ecs:List*",
          "logs:Describe*", "logs:Get*", "logs:FilterLogEvents", "logs:StartQuery", "logs:StopQuery",
          "cloudwatch:Describe*", "cloudwatch:Get*", "cloudwatch:List*",
          "ec2:Describe*",
          "sts:GetCallerIdentity"
        ]
        Resource = "*"
      },
      {
        Sid       = "EscribirJamas"
        Effect    = "Deny"
        NotAction = ["ecs:Describe*", "ecs:List*", "logs:Describe*", "logs:Get*", "logs:FilterLogEvents", "logs:StartQuery", "logs:StopQuery", "cloudwatch:Describe*", "cloudwatch:Get*", "cloudwatch:List*", "ec2:Describe*", "sts:GetCallerIdentity"]
        Resource  = "*"
      }
    ]
  })
}

# --- Rol operador: escribe, pero solo sobre la demo
resource "aws_iam_role" "agent_operator" {
  name                 = "${var.name}-agent-operator"
  permissions_boundary = aws_iam_policy.boundary.arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = "arn:aws:iam::${local.account_id}:root" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "agent_operator" {
  name = "operar-demo"
  role = aws_iam_role.agent_operator.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "OperarLaDemo"
        Effect = "Allow"
        Action = [
          "ecs:*", "logs:*", "cloudwatch:*", "ec2:Describe*", "s3:*", "budgets:*",
          "iam:PassRole", "iam:Get*", "iam:List*", "sts:GetCallerIdentity"
        ]
        Resource = "*"
      },
      {
        Sid      = "NiSeAcerqueAProduccion"
        Effect   = "Deny"
        Action   = ["rds:*", "iam:Create*", "iam:Delete*", "organizations:*", "account:*"]
        Resource = "*"
      }
    ]
  })
}
