require('dotenv').config();
const express = require('express');
const session = require('express-session');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const cookieParser = require('cookie-parser');
const { doubleCsrf } = require('csrf-csrf');
const path = require('path');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;
const IS_PROD = process.env.NODE_ENV === 'production';

// Session secret – must be set in production via .env
let sessionSecret = process.env.SESSION_SECRET;
if (!sessionSecret) {
  if (IS_PROD) {
    console.error('FATAL: SESSION_SECRET required in production');
    process.exit(1);
  }
  sessionSecret = crypto.randomBytes(48).toString('hex');
  console.warn('Using random session secret (dev only)');
}

if (process.env.TRUST_PROXY === '1') {app.set('trust proxy', 1);}

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      // Optional report-uri
      // reportUri: ['/csp-report']
    }
  }
}));
app.use(express.urlencoded({ extended: true, limit: '32kb' }));
app.use(express.json({ limit: '32kb' }));
app.use(cookieParser());
// Session store configuration
const fs = require('fs');
const sessionsDir = path.join(__dirname, 'sessions');
if (!fs.existsSync(sessionsDir)) {
  fs.mkdirSync(sessionsDir, { recursive: true });
}

if (IS_PROD) {
  // Production: use SQLite session store for persistence
  const SQLiteStore = require('connect-sqlite3')(session);
  app.use(session({
    store: new SQLiteStore({
      dir: path.join(__dirname, 'sessions'),
      db: 'sessions.sqlite',
      ttl: 4 * 60 * 60 // 4 hours
    }),
    secret: sessionSecret,
    resave: false,
    saveUninitialized: false,
    cookie: { httpOnly: true, secure: true, sameSite: 'lax', maxAge: 4 * 60 * 60 * 1000 }
  }));
} else {
  // Development & test: use default MemoryStore to avoid DB issues.
  app.use(session({
    secret: sessionSecret,
    resave: false,
    saveUninitialized: false,
    cookie: { httpOnly: true, secure: false, sameSite: 'lax' }
  }));
}

    const {
  doubleCsrfProtection,
  generateCsrfToken,
} = doubleCsrf({
  getSecret: () => sessionSecret,
  getSessionIdentifier: (req) => req.sessionID,
  cookieName: IS_PROD ? '__Host-psifi.x-csrf-token' : 'x-csrf-token',
  cookieOptions: { sameSite: 'lax', secure: IS_PROD, httpOnly: true, path: '/' },
  size: 64,
  getTokenFromRequest: (req) => req.body._csrf,
});
// Alias for backward compatibility
const generateToken = generateCsrfToken;

// CSRF protection wrapper — skip in test mode
const csrfProtection = (req, res, next) => {
  if (process.env.NODE_ENV === 'test') {
    return next();
  }
  return doubleCsrfProtection(req, res, next);
};

// CSRF protection applied per route (POST) to avoid validation on GET
app.use((req, res, next) => {
  // Ensure CSRF token is available in locals for rendering views
  let token = '';
  if (req.cookies && (req.cookies['x-csrf-token'] || req.cookies['__Host-psifi.x-csrf-token'])) {
    // Token already set by doubleCsrfProtection middleware (if any)
    token = req.cookies['x-csrf-token'] || req.cookies['__Host-psifi.x-csrf-token'];
  } else if (req.method === 'GET' && typeof generateToken === 'function') {
    // Generate token for GET requests (e.g., rendering forms)
    try {
      generateToken(req, res);
      // After generation, token cookie should be set; retrieve it
      token = req.cookies && (req.cookies['x-csrf-token'] || req.cookies['__Host-psifi.x-csrf-token']) ?
        (req.cookies['x-csrf-token'] || req.cookies['__Host-psifi.x-csrf-token']) : '';
    } catch (e) {
      console.error('CSRF token generation error', e);
    }
  }
  res.locals.csrfToken = token;
  next();
});
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));
// Rate limiting for admin routes (all /admin/*)
const adminLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many requests to admin, try again later.'
});

// Rate limiting for admin login
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: 'Too many login attempts, try again later.'
});

// Apply admin rate limiter to all admin routes
app.use('/admin', adminLimiter);


const bcrypt = require('bcryptjs'); // password hashing
// Admin credentials – must be provided via environment in production.
// For local dev we allow defaults but emit a warning.
const ADMIN_USER = process.env.ADMIN_USER || 'admin';
// Expect a bcrypt hash in production; fallback to plaintext for dev with warning.
const ADMIN_PASS_HASH = process.env.ADMIN_PASS_HASH;
const ADMIN_PASS_PLAIN = process.env.ADMIN_PASS || 'admin123';
if (IS_PROD) {
  if (!process.env.ADMIN_USER || !ADMIN_PASS_HASH) {
    console.error('FATAL: ADMIN_USER and ADMIN_PASS_HASH must be set in production');
    process.exit(1);
  }
} else {
  if (!process.env.ADMIN_USER) { console.warn('Using default admin user "admin" for dev'); }
    if (!ADMIN_PASS_HASH) { console.warn('Using plaintext admin password for dev'); }
}

function requireAdmin(req, res, next) {
  if (req.session && req.session.isAdmin) {return next();}
  res.redirect('/admin/login');
}

// Home page
app.get('/', (req, res) => {
  res.render('index', { user: req.session.isAdmin ? 'admin' : null });
});

// Admin login pages
app.get('/admin/login', csrfProtection, (req, res) => {
  // Generate CSRF token and set cookie for login form
  let csrfToken = '';
  if (typeof req.csrfToken === 'function') {
    try { csrfToken = req.csrfToken(); } catch (e) { console.error('CSRF token generation error', e); }
  }
  res.render('admin/login', { error: null, csrfToken });
});
app.post('/admin/login', loginLimiter, csrfProtection, async (req, res) => {
  const { username, password } = req.body;
  if (username !== ADMIN_USER) {
    return res.status(401).render('admin/login', { error: 'Invalid credentials' });
  }
  let valid = false;
  if (IS_PROD) {
    // Compare against stored bcrypt hash
    try {
      valid = await bcrypt.compare(password, ADMIN_PASS_HASH);
    } catch (e) {
      console.error('Bcrypt error', e);
    }
  } else {
    // Dev mode: compare plaintext
    valid = password === ADMIN_PASS_PLAIN;
  }
  if (valid) {
    req.session.isAdmin = true;
    return res.redirect('/admin');
  }
  res.status(401).render('admin/login', { error: 'Invalid credentials' });
});
app.post('/admin/logout', (req, res) => {
  req.session.destroy(() => res.redirect('/'));
});

// Admin dashboard placeholder
app.get('/admin', requireAdmin, (req, res) => {
  res.render('admin/dashboard');
});

// Global error handling (no stack in prod)
app.use((err, req, res, next) => {
  console.error(err);
  const msg = IS_PROD ? 'Server error' : err.message;
  res.status(err.status || 500).render('error', { message: msg });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Secure Express shop listening on http://localhost:${PORT}`);
  });
} else {
  module.exports = app;
}

