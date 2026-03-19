import { useEffect, useState } from 'react';
 
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8080';
 
export default function HomePage() {
  const [health, setHealth] = useState('Cargando...');
  const [tasks, setTasks] = useState([]);
  const [loadingTasks, setLoadingTasks] = useState(false);
  const [creating, setCreating] = useState(false);
  const [error, setError] = useState(null);
 
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [status, setStatus] = useState('TODO');
 
  const [actionLoadingId, setActionLoadingId] = useState(null);
 
  // NUEVO: id de la tarea en modo edición
  const [editingId, setEditingId] = useState(null);
  const [editTitle, setEditTitle] = useState('');
  const [editDescription, setEditDescription] = useState('');
  const [editStatus, setEditStatus] = useState('TODO');
 
  async function fetchHealth() {
    try {
      const res = await fetch(`${API_URL}/health-db`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const text = await res.text();
      setHealth(text);
    } catch (err) {
      setHealth(`Error: ${err.message}`);
    }
  }
 
  async function fetchTasks() {
    setLoadingTasks(true);
    setError(null);
    try {
      const res = await fetch(`${API_URL}/tasks`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      setTasks(data);
    } catch (err) {
      setError(`Error cargando tareas: ${err.message}`);
    } finally {
      setLoadingTasks(false);
    }
  }
 
  async function handleCreateTask(e) {
    e.preventDefault();
    if (!title.trim()) {
      alert('El título no puede estar vacío');
      return;
    }
    setCreating(true);
    setError(null);
    try {
      const res = await fetch(`${API_URL}/tasks`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: title.trim(), description: description.trim(), status }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(`Error al crear tarea: HTTP ${res.status} - ${text}`);
      }
      await fetchTasks();
      setTitle('');
      setDescription('');
      setStatus('TODO');
    } catch (err) {
      setError(err.message);
    } finally {
      setCreating(false);
    }
  }
 
  async function handleDeleteTask(id) {
    if (!window.confirm(`¿Eliminar la tarea ${id}?`)) return;
    setActionLoadingId(id);
    setError(null);
    try {
      const res = await fetch(`${API_URL}/tasks/${id}`, { method: 'DELETE' });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(`Error al eliminar tarea: HTTP ${res.status} - ${text}`);
      }
      await fetchTasks();
    } catch (err) {
      setError(err.message);
    } finally {
      setActionLoadingId(null);
    }
  }
 
  async function handleMarkDone(id) {
    setActionLoadingId(id);
    setError(null);
    try {
      const res = await fetch(`${API_URL}/tasks/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: 'DONE' }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(`Error al actualizar tarea: HTTP ${res.status} - ${text}`);
      }
      await fetchTasks();
    } catch (err) {
      setError(err.message);
    } finally {
      setActionLoadingId(null);
    }
  }
 
  // NUEVO: abrir formulario de edición prellenado
  function handleStartEdit(task) {
    setEditingId(task.id);
    setEditTitle(task.title);
    setEditDescription(task.description || '');
    setEditStatus(task.status);
  }
 
  // NUEVO: cancelar edición
  function handleCancelEdit() {
    setEditingId(null);
    setEditTitle('');
    setEditDescription('');
    setEditStatus('TODO');
  }
 
  // NUEVO: guardar edición via PUT /tasks/{id}
  async function handleSaveEdit(id) {
    if (!editTitle.trim()) {
      alert('El título no puede estar vacío');
      return;
    }
    setActionLoadingId(id);
    setError(null);
    try {
      const res = await fetch(`${API_URL}/tasks/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: editTitle.trim(),
          description: editDescription.trim(),
          status: editStatus,
        }),
      });
      if (!res.ok) {
        const text = await res.text();
        throw new Error(`Error al editar tarea: HTTP ${res.status} - ${text}`);
      }
      await fetchTasks();
      handleCancelEdit();
    } catch (err) {
      setError(err.message);
    } finally {
      setActionLoadingId(null);
    }
  }
 
  useEffect(() => {
    fetchHealth();
    fetchTasks();
  }, []);
 
  return (
    <div style={{ maxWidth: '800px', margin: '0 auto', padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1>Demo Full‑Stack: Next.js + Spring Boot</h1>
 
      <section style={{ marginBottom: '2rem' }}>
        <h2>Backend</h2>
        <p><strong>API_URL:</strong> {API_URL}</p>
        <p><strong>Health del backend:</strong> {health}</p>
      </section>
 
      <section style={{ marginBottom: '2rem' }}>
        <h2>Crear nueva tarea</h2>
        <form onSubmit={handleCreateTask} style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
          <label>
            Título:
            <input
              type="text"
              value={title}
              onChange={e => setTitle(e.target.value)}
              placeholder="Escribe el título"
              style={{ width: '100%', padding: '0.4rem' }}
            />
          </label>
          <label>
            Descripción:
            <textarea
              value={description}
              onChange={e => setDescription(e.target.value)}
              placeholder="Descripción (opcional)"
              style={{ width: '100%', padding: '0.4rem' }}
            />
          </label>
          <label>
            Estado:
            <select value={status} onChange={e => setStatus(e.target.value)}>
              <option value="TODO">TODO</option>
              <option value="IN_PROGRESS">IN_PROGRESS</option>
              <option value="DONE">DONE</option>
            </select>
          </label>
          <button type="submit" disabled={creating}>
            {creating ? 'Creando...' : 'Crear tarea'}
          </button>
        </form>
      </section>
 
      <section>
        <h2>Lista de tareas</h2>
        {loadingTasks && <p>Cargando tareas...</p>}
        {error && <p style={{ color: 'red' }}>{error}</p>}
        {!loadingTasks && tasks.length === 0 && <p>No hay tareas.</p>}
 
        <ul style={{ listStyle: 'none', padding: 0 }}>
          {tasks.map(task => (
            <li key={task.id} style={{ border: '1px solid #ccc', padding: '1rem', marginBottom: '0.5rem' }}>
 
              {/* MODO EDICIÓN */}
              {editingId === task.id ? (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem' }}>
                  <p><strong>ID:</strong> {task.id}</p>
                  <label>
                    Título:
                    <input
                      type="text"
                      value={editTitle}
                      onChange={e => setEditTitle(e.target.value)}
                      style={{ width: '100%', padding: '0.4rem' }}
                    />
                  </label>
                  <label>
                    Descripción:
                    <textarea
                      value={editDescription}
                      onChange={e => setEditDescription(e.target.value)}
                      style={{ width: '100%', padding: '0.4rem' }}
                    />
                  </label>
                  <label>
                    Estado:
                    <select value={editStatus} onChange={e => setEditStatus(e.target.value)}>
                      <option value="TODO">TODO</option>
                      <option value="IN_PROGRESS">IN_PROGRESS</option>
                      <option value="DONE">DONE</option>
                    </select>
                  </label>
                  <div style={{ display: 'flex', gap: '0.5rem' }}>
                    <button
                      onClick={() => handleSaveEdit(task.id)}
                      disabled={actionLoadingId === task.id}
                      style={{ backgroundColor: '#4caf50', color: 'white' }}
                    >
                      {actionLoadingId === task.id ? 'Guardando...' : 'Guardar'}
                    </button>
                    <button onClick={handleCancelEdit}>
                      Cancelar
                    </button>
                  </div>
                </div>
              ) : (
                /* MODO VISTA NORMAL */
                <>
                  <p><strong>ID:</strong> {task.id}</p>
                  <p><strong>Título:</strong> {task.title}</p>
                  <p><strong>Descripción:</strong> {task.description}</p>
                  <p><strong>Estado:</strong> {task.status}</p>
                  <p><small>Creada: {task.createdAt}</small></p>
                  <p><small>Actualizada: {task.updatedAt}</small></p>
 
                  <div style={{ display: 'flex', gap: '0.5rem', marginTop: '0.5rem' }}>
                    <button
                      onClick={() => handleStartEdit(task)}
                      disabled={actionLoadingId === task.id}
                      style={{ backgroundColor: '#2196f3', color: 'white' }}
                    >
                      Editar
                    </button>
                    <button
                      onClick={() => handleMarkDone(task.id)}
                      disabled={actionLoadingId === task.id}
                    >
                      {actionLoadingId === task.id ? 'Actualizando...' : 'Marcar como DONE'}
                    </button>
                    <button
                      onClick={() => handleDeleteTask(task.id)}
                      disabled={actionLoadingId === task.id}
                      style={{ backgroundColor: '#f44336', color: 'white' }}
                    >
                      {actionLoadingId === task.id ? 'Eliminando...' : 'Eliminar'}
                    </button>
                  </div>
                </>
              )}
            </li>
          ))}
        </ul>
      </section>
    </div>
  );
}
