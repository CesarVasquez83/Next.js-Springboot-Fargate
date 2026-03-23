# 🗂️ Task Manager — Full Stack App

REST API para gestión de tareas construida con **Java Spring Boot**, **PostgreSQL** y **Next.js**.  
Desarrollada y probada en **WSL Ubuntu** con **Docker** y **Docker Compose**.

---

## Descripción general

Proyecto demo full‑stack:

- **Backend**: Spring Boot (Java 17, Maven), API REST con endpoints:
  - `/health`, `/health-db`
  - CRUD de `/tasks`
- **Base de datos**: Postgres 16 (contenedor Docker).
- **Frontend**: Next.js (React) consumiendo la API para mostrar y gestionar tareas.

---

## Requisitos

- Docker y Docker Compose.
- (Opcional) JDK 17 + Maven + Node 20, si quieres correr sin Docker.

---

## Levantar todo con Docker

Desde la carpeta raíz del proyecto (donde está `docker-compose.yml`):

```bash
docker compose up --build
Luego:

Backend: http://localhost:8080/health-db
Frontend: http://localhost:3000
# trigger CI
