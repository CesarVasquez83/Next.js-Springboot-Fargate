# 🗂️ Task Manager — Full Stack App

REST API para gestión de tareas construida con Java Spring Boot, PostgreSQL y Next.js.
Desarrollada y probada en WSL Ubuntu con Docker.

---

## 🚀 Tecnologías

| Layer | Tecnología |
|-------|-----------|
| Backend | Java 17, Spring Boot 3.4, Hibernate ORM |
| Database | PostgreSQL 16 (Docker) |
| Frontend | Next.js, React, HTML/CSS/JavaScript |
| DevOps | Docker, Docker Compose, WSL Ubuntu |
| Testing | curl, HTTP methods |
| Version Control | Git, GitHub |

---

## 📋 Requisitos

- Java 17+
- Docker Desktop
- Maven o usar `./mvnw` incluido en el proyecto

---

## ▶️ Cómo correrlo

### 1. Clonar el repositorio
```bash
git clone https://github.com/CesarVasquez83/spring-boot-health.git
cd spring-boot-health
```

### 2. Levantar la base de datos con Docker
```bash
docker compose up -d
```

### 3. Correr el backend
```bash
./mvnw spring-boot:run
```

### 4. Abrir el frontend
Abrir el archivo `demo-frontend/pages/index.html` en el navegador

---

## 🔌 Endpoints API

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/tasks` | Listar todas las tareas |
| POST | `/tasks` | Crear una tarea |
| PUT | `/tasks/{id}` | Actualizar una tarea |
| DELETE | `/tasks/{id}` | Eliminar una tarea |
| GET | `/health-db` | Health check de la base de datos |

---

## 🧪 Ejemplo de uso con curl
```bash
# Crear una tarea
curl -i -X POST "http://localhost:8080/tasks" \
  -H "Content-Type: application/json" \
  -d '{"title":"Mi tarea","description":"Descripción","status":"TODO"}'

# Listar tareas
curl http://localhost:8080/tasks
```

---

## 👨‍💻 Autor

**César Augusto Vásquez Chinchay**
Ingeniero Electrónico | PMP® | PMI-ACP® | ITIL® 4
[LinkedIn](https://www.linkedin.com/in/cip-pmp-mba-itil-acp-césar-augusto-vásquez-chinchay-5990a895)
