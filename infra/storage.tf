resource "aws_db_subnet_group" "prefect_rds" {
  name       = "prefect-rds"
  subnet_ids = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "prefect-rds"
  }
}

resource "aws_db_parameter_group" "prefect" {
  name   = "prefect-rds"
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "db" {
  identifier             = "prefect-db"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  engine                 = "postgres"
  username               = "prefect"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.prefect_rds.name
  vpc_security_group_ids = [aws_security_group.main_sg.id]
  parameter_group_name   = aws_db_parameter_group.prefect.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}

resource "aws_s3_bucket" "data" {
  bucket = "prefect-play-data"
}
