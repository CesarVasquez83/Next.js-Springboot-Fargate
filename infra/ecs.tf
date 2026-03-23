#################################
#ECS Cluster
#################################

resource "aws_ecs_cluster" "main" {

name = "${var.project_name}-cluster"

tags = {

Name = "${var.project_name}-cluster"
}

}

#################################
#IAM Role para ECS Task Execution
#################################

resource "aws_iam_role" "ecs_task_execution" {

name = "${var.project_name}-ecs-task-execution-role"

assume_role_policy = jsonencode({

Version = "2012-10-17"

Statement = [{

  Action = "sts:AssumeRole"

  Effect = "Allow"

  Principal = {

    Service = "ecs-tasks.amazonaws.com"

  }

}]
})

}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {

role = aws_iam_role.ecs_task_execution.name

policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}
#################################
# Frontend Task Definition
#################################
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "frontend"
      image = "${var.ecr_frontend_url}:latest"
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "NEXT_PUBLIC_API_URL"
          value = "http://${aws_lb.main.dns_name}/api"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-frontend"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

#################################
# Backend Task Definition
#################################
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = "${var.ecr_backend_url}:latest"
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "SPRING_DATASOURCE_URL"
          value = "jdbc:postgresql://${aws_db_instance.postgres.address}:5432/demo"
        },
        {
          name  = "SPRING_DATASOURCE_USERNAME"
          value = var.db_username
        },
        {
          name  = "SPRING_DATASOURCE_PASSWORD"
          value = var.db_password
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-backend"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# Servicio ECS para el backend
resource "aws_ecs_service" "backend" {
  name            = "${var.project_name}-backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_1.id, aws_subnet.public_2.id] # Ajusta a tus subnets públicas
    security_groups = [aws_security_group.ecs_backend.id]                  # Ajusta al SG que creaste para backend
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"      # Debe coincidir con "name" del container en la task definition
    container_port   = 8080           # Debe coincidir con el puerto del backend
  }

  depends_on = [
    aws_lb_listener.main,
    aws_lb_target_group.backend
  ]
}

# Servicio ECS para el frontend
resource "aws_ecs_service" "frontend" {
  name            = "${var.project_name}-frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public_1.id, aws_subnet.public_2.id] # Igual que backend si es público
    security_groups = [aws_security_group.ecs_frontend.id]                 # Ajusta al SG para frontend
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"   # Debe coincidir con el container name de la task definition
    container_port   = 3000         # Puerto del frontend
  }

  depends_on = [
    aws_lb_listener.main,
    aws_lb_target_group.frontend
  ]
}

# Servicio Cloudwatch para el frontend
resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${var.project_name}-frontend"
  retention_in_days = 7
}

# Servicio Cloudwatch para el backend
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.project_name}-backend"
  retention_in_days = 7
}
