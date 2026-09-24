# Motor relacional de la plataforma.
#
# Queda definido pero APAGADO: se enciende poniendo provisionar_postgres = true
# en terraform.tfvars. Tarda entre 6 y 10 minutos en quedar disponible.
resource "random_password" "db" {
  count   = var.provisionar_postgres ? 1 : 0
  length  = 24
  special = false
}

resource "aws_secretsmanager_secret" "db" {
  count                   = var.provisionar_postgres ? 1 : 0
  name                    = "${var.name}/postgres/master"
  description             = "Credencial del motor Postgres de la plataforma."
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db" {
  count     = var.provisionar_postgres ? 1 : 0
  secret_id = aws_secretsmanager_secret.db[0].id
  secret_string = jsonencode({
    username = "dataplat"
    password = random_password.db[0].result
    engine   = "postgres"
    port     = 5432
  })
}

resource "aws_security_group" "db" {
  count       = var.provisionar_postgres ? 1 : 0
  name        = "${var.name}-postgres"
  description = "Acceso al motor Postgres"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Postgres desde el operador"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["177.222.113.46/32"]
  }

  ingress {
    description     = "Postgres desde los servicios"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "this" {
  count      = var.provisionar_postgres ? 1 : 0
  name       = var.name
  subnet_ids = aws_subnet.public[*].id
}

resource "aws_db_instance" "postgres" {
  count          = var.provisionar_postgres ? 1 : 0
  identifier     = "${var.name}-postgres"
  engine         = "postgres"
  engine_version = "16.15"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "plataforma"
  username = "dataplat"
  password = random_password.db[0].result

  db_subnet_group_name   = aws_db_subnet_group.this[0].name
  vpc_security_group_ids = [aws_security_group.db[0].id]
  publicly_accessible    = true

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true
  multi_az                = false
}

output "postgres_host" {
  description = "Vacio hasta que se provisione el motor."
  value       = try(aws_db_instance.postgres[0].address, "")
}
