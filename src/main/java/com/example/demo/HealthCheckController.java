package com.example.demo;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthCheckController {

    private final HealthCheckRepository repository;

    public HealthCheckController(HealthCheckRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/health-db")
    public String healthDb() {
        repository.save(new HealthCheck("OK"));
        long count = repository.count();
        return "HEALTHY (DB), total checks: " + count;
    }
}