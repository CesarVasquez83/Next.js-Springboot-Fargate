CREATE TABLE IF NOT EXISTS health_check (
    id BIGSERIAL PRIMARY KEY,
    message VARCHAR(255),
    created_at TIMESTAMP
);