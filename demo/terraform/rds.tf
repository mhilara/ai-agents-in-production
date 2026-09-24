# Motor relacional para la demo. Free tier: db.t4g.micro, 20 GB gp3.
# La contrasena se genera sola y se guarda en Secrets Manager: no existe en el repo.

resource "random_password" "db" {
  length  = 24
  special = false
}

resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.name}/postgres/master"
  description             = "Credencial del motor Postgres de la plataforma."
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = "dataplat"
    password = random_password.db.result
    engine   = "postgres"
    port     = 5432
  })
}

resource "aws_security_group" "db" {
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
  name       = var.name
  subnet_ids = aws_subnet.public[*].id
}

resource "aws_db_instance" "postgres" {
  identifier     = "${var.name}-postgres"
  engine         = "postgres"
  engine_version = "16.15"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "plataforma"
  username = "dataplat"
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = true

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true
  multi_az                = false
}

output "postgres_host" {
  value = aws_db_instance.postgres.address
}
