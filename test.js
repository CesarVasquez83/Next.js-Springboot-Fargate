import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 1000,
  duration: '5m',
};

export default function () {
  let res1 = http.get('http://demo-spring-alb-1003757388.us-east-1.elb.amazonaws.com/');
  check(res1, { 'frontend 200': (r) => r.status === 200 });

  let res2 = http.get('http://demo-spring-alb-1003757388.us-east-1.elb.amazonaws.com/api/tasks');
  check(res2, { 'backend 200': (r) => r.status === 200 });

  sleep(1);
}
