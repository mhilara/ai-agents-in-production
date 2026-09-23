output "cluster" {
  value = aws_ecs_cluster.this.name
}

output "service" {
  value = aws_ecs_service.app.name
}

output "log_group" {
  value = aws_cloudwatch_log_group.app.name
}

output "role_readonly" {
  description = "Perfil demo-ro: el que usa el agente."
  value       = aws_iam_role.agent_readonly.arn
}

output "role_operator" {
  description = "Perfil demo-op: solo tras un OK explicito."
  value       = aws_iam_role.agent_operator.arn
}

output "role_ci" {
  value = aws_iam_role.ci.arn
}
