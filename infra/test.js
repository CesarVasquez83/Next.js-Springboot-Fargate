
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 10,              // usuarios virtuales
  duration: '30s',      // duración total de la prueba
};

const BASE_URL = 'http://demo-spring-alb-1003757388.us-east-1.elb.amazonaws.com';

export default function () {
  // Frontend
  const resFrontend = http.get(`${BASE_URL}/`);
  check(resFrontend, {
    'frontend status is 200': (r) => r.status === 200,
  });

  // Backend
  const resBackend = http.get(`${BASE_URL}/api/tasks`);
  check(resBackend, {
    'backend status is 200': (r) => r.status === 200,
  });

  sleep(1);
}
