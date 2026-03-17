package com.example.demo.web.dto;

import com.example.demo.domain.TaskStatus;
import jakarta.validation.constraints.NotBlank;

public class TaskUpdateRequest {
    @NotBlank
    public String title;

    public String description;

    public TaskStatus status;
}
