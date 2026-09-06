/**
 * Basic authentication tests for secure‑express‑shop.
 * Uses supertest to spin up the Express app (exported from server.js).
 */

/* global describe, test, expect */
process.env.NODE_ENV = 'test';
const request = require('supertest');
const app = require('../server');

describe('Admin authentication flow (dev mode)', () => {
  // Ensure we run in dev mode – the test process does not set NODE_ENV, so IS_PROD will be false.
  test('GET /admin/login returns login page', async () => {
    const res = await request(app).get('/admin/login');
    expect(res.statusCode).toBe(200);
    expect(res.text).toMatch(/admin login/i);
  });

  test('POST /admin/login with wrong credentials fails', async () => {
    const res = await request(app)
      .post('/admin/login')
      .type('form')
      .send({ username: 'admin', password: 'wrong' });
    expect(res.statusCode).toBe(401);
    expect(res.text).toMatch(/invalid credentials/i);
  });

  test('POST /admin/login with default dev credentials succeeds', async () => {
    const res = await request(app)
      .post('/admin/login')
      .type('form')
      .send({ username: 'admin', password: 'admin123' });
    // Successful login redirects to /admin
    expect(res.statusCode).toBe(302);
    expect(res.headers.location).toBe('/admin');
    // Cookie should be set for session
    expect(res.headers['set-cookie']).toBeDefined();
  });
});
