# Define ECS resources.

resource "aws_ecs_cluster" "this" {
  name = "app"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode(
    [
      {
        name      = "frontend"
        image     = "nginx"
        essential = true
        portMappings = [{
          protocol      = "tcp"
          containerPort = 80
          hostPort      = 80
        }]
      }
    ]
  )
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "app-ecsTaskExecutionRole"

  assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
                {
                    "Action": "sts:AssumeRole",
                    "Principal": {
                    "Service": "ecs-tasks.amazonaws.com"
                    },
                    "Effect": "Allow",
                    "Sid": ""
                }
            ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "service" {
  name        = "allow_lb_ports"
  description = "Allow LB ports"
  vpc_id      = module.vpc.result.vpc.id

  ingress {
    description     = "Frontend from LB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  ingress {
    description     = "Backend from public"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_ecs_service" "this" {
  name                               = "app"
  cluster                            = aws_ecs_cluster.this.id
  task_definition                    = aws_ecs_task_definition.app.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  health_check_grace_period_seconds  = 120
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [aws_security_group.service.id]
    subnets          = [for subnet in module.vpc.result.private_subnets : subnet.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 80
  }
}
