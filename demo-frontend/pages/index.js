// pages/index.js

export default function Home({ healthDb, tasks, tasksError }) {
  return (
    <div style={{ fontFamily: 'sans-serif', padding: '2rem' }}>
      <h1>Demo Next.js + Spring Boot</h1>

      {/* Sección HEALTH */}
      <section style={{ marginTop: '2rem' }}>
        <h2>Health check del backend</h2>
        <p>
          Respuesta de <code>/health-db</code>:
        </p>
        <pre
          style={{
            background: '#f5f5f5',
            padding: '1rem',
            borderRadius: '4px',
            overflowX: 'auto',
          }}
        >
          {healthDb}
        </pre>
      </section>

      {/* Sección TASKS */}
      <section style={{ marginTop: '2rem' }}>
        <h2>Lista de tareas (/tasks)</h2>

        {tasksError && (
          <p style={{ color: 'red' }}>
            Error al cargar tareas: {tasksError}
          </p>
        )}

        {!tasksError && (!tasks || tasks.length === 0) && (
          <p>No hay tareas todavía.</p>
        )}

        {!tasksError && tasks && tasks.length > 0 && (
          <ul>
            {tasks.map((t) => (
              <li key={t.id} style={{ marginBottom: '0.5rem' }}>
                <strong>{t.title}</strong> – {t.description}{' '}
                <span style={{ fontSize: '0.9rem', color: '#555' }}>
                  [{t.status}]
                </span>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}

export async function getServerSideProps() {
  let healthDb = 'sin respuesta';
  let tasks = [];
  let tasksError = '';

  // Llamada a /health-db
  try {
    const res = await fetch('http://localhost:8080/health-db');
    healthDb = await res.text();
  } catch (err) {
    healthDb = 'Error llamando a http://localhost:8080/health-db: ' + err.message;
  }

  // Llamada a /tasks
  try {
    const resTasks = await fetch('http://localhost:8080/tasks');
    if (!resTasks.ok) {
      tasksError = `HTTP ${resTasks.status}`;
    } else {
      tasks = await resTasks.json();
    }
  } catch (err) {
    tasksError = 'Error llamando a /tasks: ' + err.message;
  }

  return {
    props: {
      healthDb,
      tasks,
      tasksError,
    },
  };
}