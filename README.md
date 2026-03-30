# 🚀 Next.js + Spring Boot + AWS ECS Fargate

Full-stack app con autenticación JWT desplegada en AWS con infraestructura como código.

**Stack:** Next.js · Spring Boot · Spring Security · JWT · PostgreSQL · AWS ECS Fargate · ALB · RDS · Terraform · Docker · GitHub Actions

---

## 🏗️ Arquitectura
```
Internet → ALB → /api/* → ECS (Spring Boot + JWT) → RDS PostgreSQL
               → /*     → ECS (Next.js)
```

- **Frontend**: Next.js en ECS Fargate (puerto 3000) — pantalla login/register con JWT
- **Backend**: Spring Boot en ECS Fargate (puerto 8080) — Spring Security 6, endpoints protegidos por usuario
- **Base de datos**: RDS PostgreSQL (db.t3.micro) en subredes privadas
- **Load Balancer**: ALB con routing por path (`/api/*` → backend, `/*` → frontend)
- **Infra**: Terraform — VPC, subnets, SGs, ECS, RDS, ALB, IAM (29 recursos)
- **CI/CD**: GitHub Actions → tests → build → push a ECR → deploy a ECS
- **Observabilidad**: CloudWatch dashboard (latencia p50/p95/p99, errores 4xx/5xx, CPU/Memoria ECS), alarms configuradas

---

## 🔐 Autenticación JWT

- `POST /api/auth/register` — crea usuario y devuelve JWT
- `POST /api/auth/login` — autentica y devuelve JWT
- Todos los endpoints `/api/tasks/**` requieren `Authorization: Bearer <token>`
- Cada usuario solo ve y modifica sus propias tareas
- JWT_SECRET inyectado como variable de entorno segura en ECS y GitHub Secrets

---

## 🚀 Correr localmente
```bash
docker compose up --build
```

- Frontend: http://localhost:3000
- Backend: http://localhost:8080/api/health-db

Requiere archivo `.env` en la raíz con:
```
JWT_SECRET=tu_secret_base64
```

---

## ☁️ Infraestructura AWS
```bash
cd infra
export TF_VAR_project_name="demo-spring"
export TF_VAR_db_username="tu_usuario"
export TF_VAR_db_password="tu_password"
export TF_VAR_jwt_secret="tu_secret_base64"
export TF_VAR_ecr_backend_url="<account>.dkr.ecr.us-east-1.amazonaws.com/demo-backend"
export TF_VAR_ecr_frontend_url="<account>.dkr.ecr.us-east-1.amazonaws.com/demo-frontend"
terraform apply
```

---

## 📁 Estructura
```
├── src/                        # Backend Spring Boot
│   └── main/java/com/example/demo/
│       ├── domain/             # Entidades (Task, User)
│       ├── repo/               # Repositorios JPA
│       ├── security/           # JWT Filter, Security Config, UserDetailsService
│       ├── service/            # Lógica de negocio
│       └── web/                # Controllers (Auth, Task, Health)
├── demo-frontend/              # Frontend Next.js
├── infra/                      # Terraform
├── Dockerfile                  # Backend
├── demo-frontend/Dockerfile    # Frontend
├── docker-compose.yml          # Local dev
└── .github/workflows/          # CI/CD pipeline
```

---

## 🔌 API Endpoints

| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| GET | /api/health | ❌ | Health check |
| GET | /api/health-db | ❌ | Health check con DB |
| POST | /api/auth/register | ❌ | Registro → devuelve JWT |
| POST | /api/auth/login | ❌ | Login → devuelve JWT |
| GET | /api/tasks | ✅ | Listar tareas del usuario |
| POST | /api/tasks | ✅ | Crear tarea |
| PUT | /api/tasks/{id} | ✅ | Actualizar tarea |
| DELETE | /api/tasks/{id} | ✅ | Eliminar tarea |

---

## 📊 Observabilidad

- CloudWatch Dashboard: latencia ALB (p50/p95/p99), errores 4xx/5xx, CPU/Memoria ECS backend/frontend
- Metric Alarms: errores 5xx, alta latencia, CPU alto
- Load testing con k6

---

## 🗺️ Roadmap

- [ ] Dominio propio + HTTPS (Route 53 + ACM)
- [ ] AWS Secrets Manager para credenciales
- [ ] ECS en subnets privadas (NAT Gateway)
