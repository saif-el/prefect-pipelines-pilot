resource "aws_ecs_cluster" "ecs_cluster" {
  name = "prefect-play-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cp_register" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = ["FARGATE"]
}


#################################### PREFECT SERVER ####################################

resource "aws_ecs_task_definition" "prefect_server_task_definition" {
  family = "prefect-play-server"
  cpu    = 512
  memory = 1024

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  container_definitions = jsonencode([
    {
      name    = "prefect-play-server"
      image   = "prefecthq/prefect:2-python3.9"
      command = [
        "prefect", "server", "start", "--host", "0.0.0.0", "--port", "4200"
      ]
      essential   = true,
      cpu         = 512
      memory      = 1024
      environment = [
        {
          name  = "PREFECT_API_DATABASE_CONNECTION_URL"
          value = sensitive("postgresql+asyncpg://${aws_db_instance.db.username}:${var.db_password}@${aws_db_instance.db.endpoint}/prefect")
        },
        {
          name  = "PREFECT_API_URL"
          value = "0.0.0.0:4200"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-group         = aws_cloudwatch_log_group.prefect_server_log_group.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "server"
        }
      }
      portMappings = [
        {
          "containerPort" : 4200,
          "hostPort" : 4200,
          "protocol" : "tcp"
        }
      ]
    },
  ])

  // Execution role allows ECS to create tasks and services
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  // Task role allows tasks and services to access other AWS resources
  task_role_arn = aws_iam_role.ecs_task_role.arn
}

resource "aws_ecs_service" "prefect_server_service" {
  name            = "prefect-play-server"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.prefect_server_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.main_sg.id]
    assign_public_ip = true
    subnets          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.prefect_server.arn
  }
}


#################################### PREFECT WORKER ####################################

resource "aws_ecs_task_definition" "prefect_worker_task_definition" {
  family = "prefect-play-worker"
  cpu    = 512
  memory = 1024

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  container_definitions = jsonencode([
    {
      name    = "prefect-play-worker"
      image   = "prefecthq/prefect:2-python3.9"
      command = [
        "prefect", "agent", "start", "-p", var.work_pool_name
      ]
      cpu         = 128
      memory      = 256
      environment = [
        {
          name  = "PREFECT_API_URL"
          value = "http://server.prefect.net:4200/api"
        },
        {
          name  = "EXTRA_PIP_PACKAGES"
          value = "prefect-aws s3fs"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-group         = aws_cloudwatch_log_group.prefect_worker_log_group.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "worker"
        }
      }
    }
  ])

  // Execution role allows ECS to create tasks and services
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  // Task role allows tasks and services to access other AWS resources
  task_role_arn = aws_iam_role.ecs_task_role.arn
}

resource "aws_ecs_service" "prefect_worker_service" {
  name            = "prefect-play-worker"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.prefect_worker_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.main_sg.id]
    assign_public_ip = true
    subnets          = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  }
}
