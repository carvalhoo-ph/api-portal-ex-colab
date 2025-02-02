import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '30s', target: 20 }, // ramp up to 20 users
    { duration: '10m', target: 20 },  // stay at 20 users for 1 minute
    { duration: '30s', target: 0 },  // ramp down to 0 users
  ],
};

export default function () {
  // Testar o endpoint /login
  let resLogin = http.get('https://4fr9f330c6.execute-api.us-east-1.amazonaws.com/prod/login');
  check(resLogin, { 'status was 200': (r) => r.status == 200 });
  sleep(1);

  // Testar o endpoint /periodo-demonstrativo
  let resPeriodoDemonstrativo = http.get('https://4fr9f330c6.execute-api.us-east-1.amazonaws.com/prod/periodo-demonstrativo');
  check(resPeriodoDemonstrativo, { 'status was 200': (r) => r.status == 200 });
  sleep(1);

  // Testar o endpoint /demonstrativo-pgto
  let resDemonstrativoPgto = http.get('https://4fr9f330c6.execute-api.us-east-1.amazonaws.com/prod/demonstrativo-pgto');
  check(resDemonstrativoPgto, { 'status was 200': (r) => r.status == 200 });
  sleep(1);
}
