resource "aws_iam_role" "ecs_agent_role" {
  name               = "prefect-play-ecs-agent-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  ]
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "prefect-play-ecs-agent"
  role = aws_iam_role.ecs_agent_role.name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "prefect-play-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name   = "prefect-create-log-group"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogGroup",
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "prefect-play-ecs-task-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name   = "prefect-play-ecs-task-policy"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action = [
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs",
            "ecs:DeregisterTaskDefinition",
            "ecs:DescribeTaskDefinition",
            "ecs:DescribeTasks",
            "ecs:RegisterTaskDefinition",
            "ecs:RunTask",
            "iam:PassRole",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:GetLogEvents",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = ["s3:*"]
          Effect   = "Allow"
          Resource = [
            aws_s3_bucket.data.arn,
            "${aws_s3_bucket.data.arn}/*"
          ]
        }
      ]
    })
  }
}
