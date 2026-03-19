package com.example.demo.service;

import com.example.demo.domain.Task;
import com.example.demo.repo.TaskRepository;
import com.example.demo.web.dto.TaskUpdateRequest;
import com.example.demo.service.TaskNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class TaskService {

  private final TaskRepository repo;

  public TaskService(TaskRepository repo) {
    this.repo = repo;
  }

  public List<Task> list() {
    return repo.findAll();
  }

  public Task create(Task task) {
    return repo.save(task);
  }

  public Task getById(Long id) {
    return repo.findById(id)
        .orElseThrow(() -> new TaskNotFoundException(id));
  }

@Transactional
public Task update(Long id, TaskUpdateRequest req) {
  Task t = getById(id);

  if (req.title != null && !req.title.isBlank()) {
    t.setTitle(req.title);
  }

  if (req.description != null) {
    t.setDescription(req.description);
  }

  if (req.status != null) {
    t.setStatus(req.status);
  }

  return repo.save(t);
}

@Transactional
public void delete(Long id) {
  Task t = getById(id);
  repo.delete(t);
}


}


