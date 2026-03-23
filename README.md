# 🚀 Next.js + Spring Boot + AWS ECS Fargate

Full-stack demo app desplegada en AWS con infraestructura como código.

**Stack:** Next.js · Spring Boot · PostgreSQL · AWS ECS Fargate · ALB · RDS · Terraform · Docker · GitHub Actions

---

## 🏗️ Arquitectura
```
Internet → ALB → /api/* → ECS (Spring Boot) → RDS PostgreSQL
               → /*     → ECS (Next.js)
```

- **Frontend**: Next.js en ECS Fargate (puerto 3000)
- **Backend**: Spring Boot en ECS Fargate (puerto 8080)
- **Base de datos**: RDS PostgreSQL en subredes privadas
- **Load Balancer**: ALB con routing por path (`/api/*` → backend)
- **Infra**: Terraform (VPC, subnets, SGs, ECS, RDS, ALB, IAM)
- **CI/CD**: GitHub Actions → build → push a ECR → deploy a ECS

---

## 🚀 Correr localmente
```bash
docker compose up --build
```

- Frontend: http://localhost:3000
- Backend: http://localhost:8080/api/health-db

---

## ☁️ Infraestructura AWS
```bash
cd infra
export TF_VAR_project_name="demo-spring"
export TF_VAR_db_username="miusuario"
export TF_VAR_db_password="mipassword"
export TF_VAR_ecr_backend_url=""
export TF_VAR_ecr_frontend_url=""
terraform apply
```

---

## 📁 Estructura
```
├── src/                  # Backend Spring Boot
├── demo-frontend/        # Frontend Next.js
├── infra/                # Terraform
├── Dockerfile            # Backend
├── demo-frontend/Dockerfile  # Frontend
└── docker-compose.yml    # Local dev
```

---

## 🔌 API Endpoints

| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | /api/health | Health check |
| GET | /api/health-db | Health check con DB |
| GET | /api/tasks | Listar tareas |
| POST | /api/tasks | Crear tarea |
| PUT | /api/tasks/{id} | Actualizar tarea |
| DELETE | /api/tasks/{id} | Eliminar tarea |
# CD test
