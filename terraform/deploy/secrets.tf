resource "aws_secretsmanager_secret" "db" {
  name = "${local.name_prefix}-db-credentials"

  tags = {
    Name = "${local.name_prefix}-db-secret"
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    host     = aws_db_instance.main.address
    port     = tostring(aws_db_instance.main.port)
    dbname   = var.db_name
  })
}
