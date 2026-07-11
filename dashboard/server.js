require('dotenv').config();
const express = require('express');
const morgan = require('morgan');
const axios = require('axios');
const path = require('path');
const fs = require('fs');

const app = express();
app.use(morgan('combined'));
app.use(express.json());

// Simple health check
app.get('/health', (req, res) => res.json({status: 'ok'}));

// Proxy endpoint – catches any npm or pypi request and forwards it.
app.use('/*', async (req, res) => {
  try {
    const targetUrl = `${process.env.UPSTREAM_REGISTRY || 'https://registry.npmjs.org'}${req.originalUrl}`;
    const upstreamResp = await axios({method: req.method, url: targetUrl, responseType: 'stream'});
    // TODO: invoke scanning scripts (npm audit, pip-audit, gitleaks) on the fetched tarball before piping.
    // Placeholder: just pipe response.
    upstreamResp.data.pipe(res);
    res.status(upstreamResp.status);
  } catch (e) {
    console.error('Proxy error:', e.message);
    res.status(502).json({error: 'Upstream proxy failure'});
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => console.log(`Secure Registry Proxy listening on port ${PORT}`));
