/* global describe, it, expect, beforeEach, jest */
const request = require('supertest');
const app = require('../server');

describe('CSRF Protection (test mode bypass)', () => {
  let agent;
  let csrfToken;
  let csrfCookie;

  beforeEach(async () => {
    agent = request.agent(app);
    const res = await agent.get('/admin/login');
    const tokenMatch = res.text.match(/name="_csrf" value="([^\\"]+)"/);
    if (tokenMatch) {
      csrfToken = tokenMatch[1];
    }
    if (Array.isArray(res.headers['set-cookie'])) {
      csrfCookie = res.headers['set-cookie'][0].split(';')[0];
    } else {
      csrfCookie = res.headers['set-cookie'];
    }
  });

  it('should accept login with valid CSRF token', async () => {
    const res = await agent
      .post('/admin/login')
      .set('Cookie', csrfCookie)
      .send({ username: 'admin', password: 'admin123', _csrf: csrfToken });
    expect(res.statusCode).toBe(302);
  });
});
