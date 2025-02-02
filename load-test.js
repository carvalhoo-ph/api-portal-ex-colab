import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 30 }, // ramp up to 10 users
    { duration: '1m', target: 30 },  // stay at 10 users for 1 minute
    { duration: '30s', target: 0 },  // ramp down to 0 users
  ],
};

const API_URL = __ENV.API_URL;

export default function () {
  // Test the 'periodo-demonstrativo' endpoint
  let res1 = http.get(`${API_URL}/periodo-demonstrativo`);
  check(res1, {
    'status is 200': (r) => r.status === 200,
  });

  // Test the 'login' endpoint
  let res2 = http.post(`${API_URL}/login`, { username: 'test', password: 'test' });
  check(res2, {
    'status is 200': (r) => r.status === 200,
  });

  // Test the 'demonstrativo-pgto' endpoint
  let res3 = http.get(`${API_URL}/demonstrativo-pgto`);
  check(res3, {
    'status is 200': (r) => r.status === 200,
  });

  sleep(1);
}
