import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 20 }, // ramp up to 20 users
    { duration: '10m', target: 20 },  // stay at 20 users for 10 minutes
    { duration: '30s', target: 0 },  // ramp down to 0 users
  ],
};

export default function () {
  const apiUrl = __ENV.API_URL;

  // Testar o endpoint /login
  let resLogin = http.get(`${apiUrl}/login`);
  check(resLogin, { 'status was 200': (r) => r.status == 200 });
  sleep(1);

  // Testar o endpoint /periodo-demonstrativo
  let resPeriodoDemonstrativo = http.get(`${apiUrl}/periodo-demonstrativo`);
  check(resPeriodoDemonstrativo, { 'status was 200': (r) => r.status == 200 });
  sleep(1);

  // Testar o endpoint /demonstrativo-pgto
  let resDemonstrativoPgto = http.get(`${apiUrl}/demonstrativo-pgto`);
  check(resDemonstrativoPgto, { 'status was 200': (r) => r.status == 200 });
  sleep(1);
}
