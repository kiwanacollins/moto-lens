/**
 * Vercel Serverless Function - API Proxy
 * This proxies requests from HTTPS frontend to HTTP backend
 * to avoid mixed content errors
 */

export default async function handler(req, res) {
  // Enable CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // Get the API path from the URL
  // Example: /api/proxy/vin/decode -> path = vin/decode
  const pathArray = req.url.split('/api/proxy/');
  const path = pathArray[1] || '';
  
  if (!path) {
    return res.status(400).json({ error: 'Missing path' });
  }

  // Backend URL
  const BACKEND_URL = process.env.BACKEND_API_URL || 'http://207.180.249.87/api';
  const targetUrl = `${BACKEND_URL}/${path}`;

  try {
    // Prepare request options
    const options = {
      method: req.method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    // Add body for POST/PUT requests
    if (req.method !== 'GET' && req.method !== 'HEAD' && req.body) {
      options.body = JSON.stringify(req.body);
    }

    // Forward the request to backend
    const response = await fetch(targetUrl, options);
    const data = await response.json();
    
    // Return the backend response
    return res.status(response.status).json(data);
  } catch (error) {
    console.error('Proxy error:', error);
    return res.status(500).json({ 
      error: 'Proxy failed', 
      message: error.message 
    });
  }
}
