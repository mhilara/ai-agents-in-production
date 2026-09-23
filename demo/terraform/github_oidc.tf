# CI sin llaves de larga duracion: GitHub se identifica con OIDC y asume el rol.
# No hay un solo secreto de AWS guardado en el repo.

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "ci" {
  name                 = "${var.name}-ci"
  permissions_boundary = aws_iam_policy.boundary.arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          # Solo main de este repo. Un fork o una rama no entran.
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/heads/main"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "ci" {
  name = "aplicar-el-fix"
  role = aws_iam_role.ci.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "TerraformSobreLaDemo"
        Effect   = "Allow"
        Action   = ["ecs:*", "logs:*", "ec2:Describe*", "s3:*", "iam:Get*", "iam:List*", "iam:PassRole", "sts:GetCallerIdentity", "budgets:*"]
        Resource = "*"
      },
      {
        Sid      = "NiIdentidadesNiProduccion"
        Effect   = "Deny"
        Action   = ["iam:Create*", "iam:Delete*", "iam:Attach*", "rds:*", "organizations:*", "account:*"]
        Resource = "*"
      }
    ]
  })
}
