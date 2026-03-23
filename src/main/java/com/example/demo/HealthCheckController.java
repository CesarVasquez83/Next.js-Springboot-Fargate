package com.example.demo;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthCheckController {

    private final HealthCheckRepository repository;

    public HealthCheckController(HealthCheckRepository repository) {
        this.repository = repository;
    }

    @CrossOrigin(origins = "http://localhost:3000")
    @GetMapping("/api/health-db")
    public String healthDb() {
        repository.save(new HealthCheck("OK"));
        long count = repository.count();
        return "HEALTHY (DB), CORS TEST, total checks: " + count;
    }
}