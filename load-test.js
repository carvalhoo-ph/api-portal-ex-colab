import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 20 },
    { duration: '1m30s', target: 10 },
    { duration: '20s', target: 0 },
  ],
};

const API_URL = __ENV.API_URL;

export default function () {
  // Test the 'periodo-demonstrativo' endpoint
  let res1 = http.get(`${API_URL}/periodo-demonstrativo`);
  check(res1, {
    'status is 200': (r) => r.status === 200,
    'response body is not empty': (r) => r.body && r.body.length > 0,
  });

  // Test the 'login' endpoint with valid credentials
  let res2 = http.post(`${API_URL}/login`, JSON.stringify({ username: 'test', password: 'test' }), {
    headers: { 'Content-Type': 'application/json' },
  });
  check(res2, {
    'status is 200': (r) => r.status === 200,
    'response body contains token': (r) => JSON.parse(r.body).token !== undefined,
  });

  // Test the 'login' endpoint with invalid credentials
  let res3 = http.post(`${API_URL}/login`, JSON.stringify({ username: 'invalid', password: 'invalid' }), {
    headers: { 'Content-Type': 'application/json' },
  });
  check(res3, {
    'status is 401': (r) => r.status === 401,
  });

  // Test the 'demonstrativo-pgto' endpoint
  let res4 = http.get(`${API_URL}/demonstrativo-pgto`);
  check(res4, {
    'status is 200': (r) => r.status === 200,
    'response body is not empty': (r) => r.body && r.body.length > 0,
  });

  // Test the 'user-profile' endpoint
  let res5 = http.get(`${API_URL}/user-profile`);
  check(res5, {
    'status is 200': (r) => r.status === 200,
    'response body is not empty': (r) => r.body && r.body.length > 0,
  });

  sleep(1);
}
