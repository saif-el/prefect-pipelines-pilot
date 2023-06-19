data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }
}

resource "aws_launch_template" "ecs_launch_template" {
  name                   = "prefect-play-launch-template"
  image_id               = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.main_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_agent.name
  }

  user_data = base64encode(<<-EOL
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config
    EOL
  )
}

resource "aws_autoscaling_group" "ecs_asg" {
  name                = "prefect-play-asg"
  vpc_zone_identifier = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }

  min_size                  = 2
  max_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
}

resource "aws_ecs_capacity_provider" "ecs_cp" {
  name = "prefect-play-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 2
    }
  }
}
