package com.example.demo.web.dto;

import com.example.demo.domain.TaskStatus;
import java.time.Instant;

public class TaskResponse {
  public Long id;
  public String title;
  public String description;
  public TaskStatus status;
  public Instant createdAt;
  public Instant updatedAt;
}
