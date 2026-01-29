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

    // Check content type before parsing
    const contentType = response.headers.get('content-type');

    if (contentType && contentType.includes('application/json')) {
      const data = await response.json();
      return res.status(response.status).json(data);
    } else {
      // Non-JSON response from backend
      const text = await response.text();
      console.error('Non-JSON response from backend:', text.substring(0, 200));

      // Check for common error patterns
      if (text.includes('Request Entity Too Large') || response.status === 413) {
        return res.status(413).json({
          success: false,
          error: 'Image too large',
          message: 'Image file is too large. Please use a smaller image (max 10MB).'
        });
      }

      if (response.status === 502 || response.status === 503 || response.status === 504) {
        return res.status(response.status).json({
          success: false,
          error: 'Backend unavailable',
          message: 'The analysis service is temporarily unavailable. Please try again in a moment.'
        });
      }

      return res.status(response.status || 500).json({
        success: false,
        error: 'Invalid response',
        message: 'Server returned an unexpected response. Please try again.'
      });
    }
  } catch (error) {
    console.error('Proxy error:', error);

    // Handle specific error types
    if (error.cause?.code === 'ECONNREFUSED') {
      return res.status(503).json({
        success: false,
        error: 'Backend offline',
        message: 'Analysis server is not responding. Please try again later.'
      });
    }

    if (error.name === 'AbortError' || error.cause?.code === 'ETIMEDOUT') {
      return res.status(504).json({
        success: false,
        error: 'Request timeout',
        message: 'Analysis is taking too long. Please try with a smaller image.'
      });
    }

    return res.status(500).json({
      success: false,
      error: 'Proxy failed',
      message: 'Failed to connect to analysis service. Please try again.'
    });
  }
}
