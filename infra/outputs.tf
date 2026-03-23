output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.main.id
}

output "public_subnets_ids" {
  description = "IDs de las subnets públicas"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnets_ids" {
  description = "IDs de las subnets privadas"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "alb_dns_name" {
  description = "DNS público del Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "rds_endpoint" {
  description = "Endpoint de la base de datos RDS"
  value       = aws_db_instance.postgres.endpoint
}

output "ecs_cluster_name" {
  description = "Nombre del ECS Cluster"
  value       = aws_ecs_cluster.main.name
}

output "backend_service_name" {
  description = "Nombre del ECS service para backend"
  value       = aws_ecs_service.backend.name
}

output "frontend_service_name" {
  description = "Nombre del ECS service para frontend"
  value       = aws_ecs_service.frontend.name
}