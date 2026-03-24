#################################
# CloudWatch Dashboard
#################################

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "ALB - Latencia (p50, p95, p99)",
          "period" : 60,
          "stat" : "p99",
          "region" : var.aws_region,
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix, { "stat" : "p50", "label" : "p50" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix, { "stat" : "p95", "label" : "p95" }],
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix, { "stat" : "p99", "label" : "p99" }]
          ]
        }
      },
      {
        "type" : "metric",
        "x" : 12,
        "y" : 0,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "ALB - Errores 4xx y 5xx",
          "period" : 60,
          "stat" : "Sum",
          "region" : var.aws_region,
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", aws_lb.main.arn_suffix, { "label" : "4xx" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", aws_lb.main.arn_suffix, { "label" : "5xx" }]
          ]
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 6,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "ALB - Request Count",
          "period" : 60,
          "stat" : "Sum",
          "region" : var.aws_region,
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix]
          ]
        }
      },
      {
        "type" : "metric",
        "x" : 12,
        "y" : 6,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "ECS - CPU y Memoria Frontend",
          "period" : 60,
          "region" : var.aws_region,
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.frontend.name, { "stat" : "Average", "label" : "CPU %" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.frontend.name, { "stat" : "Average", "label" : "Memory %" }]
          ]
        }
      },
      {
        "type" : "metric",
        "x" : 0,
        "y" : 12,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "ECS - CPU y Memoria Backend",
          "period" : 60,
          "region" : var.aws_region,
          "view" : "timeSeries",
          "stacked" : false,
          "metrics" : [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.backend.name, { "stat" : "Average", "label" : "CPU %" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.backend.name, { "stat" : "Average", "label" : "Memory %" }]
          ]
        }
      },
      {
        "type" : "log",
        "x" : 0,
        "y" : 18,
        "width" : 24,
        "height" : 6,
        "properties" : {
          "title" : "Backend Logs - Errores",
          "query" : "SOURCE '/ecs/${var.project_name}-backend' | fields @timestamp, @message | filter @message like /ERROR/ | sort @timestamp desc | limit 20",
          "region" : var.aws_region,
          "stacked" : false,
          "view" : "table",
          "period" : 300
        }
      }
    ]
  })
}

#################################
# Alarma - 5xx errors
#################################
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-alb-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Mas de 10 errores 5xx en 1 minuto"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

#################################
# Alarma - 4xx errors
#################################
resource "aws_cloudwatch_metric_alarm" "alb_4xx" {
  alarm_name          = "${var.project_name}-alb-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 50
  alarm_description   = "Mas de 50 errores 4xx en 1 minuto"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

#################################
# Alarma - Latencia alta
#################################
resource "aws_cloudwatch_metric_alarm" "alb_latency" {
  alarm_name          = "${var.project_name}-alb-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  extended_statistic  = "p99"
  threshold           = 2
  alarm_description   = "Latencia p99 mayor a 2 segundos"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }
}

#################################
# Alarma - ECS Backend CPU alta
#################################
resource "aws_cloudwatch_metric_alarm" "ecs_backend_cpu" {
  alarm_name          = "${var.project_name}-backend-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU del backend mayor al 80%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.backend.name
  }
}

#################################
# Alarma - ECS Backend memoria alta
#################################
resource "aws_cloudwatch_metric_alarm" "ecs_backend_memory" {
  alarm_name          = "${var.project_name}-backend-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Memoria del backend mayor al 80%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.backend.name
  }
}

#################################
# Log Metric Filter - Errores backend
#################################
resource "aws_cloudwatch_log_metric_filter" "backend_errors" {
  name           = "${var.project_name}-backend-errors"
  log_group_name = "/ecs/${var.project_name}-backend"
  pattern        = "ERROR"

  metric_transformation {
    name      = "BackendErrorCount"
    namespace = "${var.project_name}/Application"
    value     = "1"
  }
}

#################################
# Alarma - Errores en logs del backend
#################################
resource "aws_cloudwatch_metric_alarm" "backend_log_errors" {
  alarm_name          = "${var.project_name}-backend-log-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BackendErrorCount"
  namespace           = "${var.project_name}/Application"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Mas de 5 errores en logs del backend en 1 minuto"
  treat_missing_data  = "notBreaching"
}