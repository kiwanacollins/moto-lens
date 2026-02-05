# 🔒 MotoLens Security Quick Reference

Quick reference guide for security features and best practices.

---

## 🚀 Quick Start

### Enable All Security Features

```javascript
// backend/src/server.js

import {
  securityHeaders,
  globalRateLimit,
  sanitizeInput,
  preventXSS,
  validateSqlInput,
  securityLogger,
} from './middleware/security.js';

// Apply in order
app.use(securityHeaders);
app.use(securityLogger);
app.use(sanitizeInput);
app.use(validateSqlInput);
app.use(preventXSS);

if (process.env.NODE_ENV === 'production') {
  app.use(globalRateLimit);
}
```

---

## 📋 Rate Limits Cheat Sheet

| Endpoint | Window | Max Requests | Purpose |
|----------|--------|--------------|---------|
| Global API | 15 min | 100 | API abuse prevention |
| Login | 15 min | 10 | Brute force prevention |
| Registration | 1 hour | 3 | Mass account prevention |
| Password Reset | 1 hour | 3 | Reset abuse prevention |
| Email Verification | 1 hour | 10 | Email spam prevention |
| VIN Decode | 15 min | 30 | API quota protection |

---

## 🔐 Security Headers Enabled

- ✅ Content-Security-Policy
- ✅ Strict-Transport-Security (HSTS)
- ✅ X-Frame-Options: DENY
- ✅ X-Content-Type-Options: nosniff
- ✅ Referrer-Policy: strict-origin-when-cross-origin
- ✅ X-XSS-Protection

---

## 🛡️ Protection Layers

### 1. Input Sanitization
- Removes `<script>` tags
- Removes `<iframe>` tags
- Removes inline event handlers
- Removes `javascript:` protocol
- Removes null bytes

### 2. SQL Injection Detection
- Detects SQL keywords (OR, UNION, DROP, etc.)
- Blocks suspicious patterns
- Logs attempts with IP

### 3. XSS Prevention
- Input sanitization
- Security headers
- Content-Type validation

### 4. CSRF Protection
- Token-based validation
- Session-scoped tokens
- 1-hour expiry

---

## 🔍 Testing Commands

### Test Security Headers
```bash
curl -I http://localhost:3001/api/health
```

### Test Rate Limiting
```bash
for i in {1..11}; do
  curl -X POST http://localhost:3001/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@test.com","password":"wrong"}'
done
```

### Test Input Sanitization
```bash
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","firstName":"<script>alert(1)</script>","password":"Test123!"}'
```

### Test SQL Injection Protection
```bash
curl -X GET "http://localhost:3001/api/vin/decode/ABC OR 1=1--"
```

---

## ⚠️ Production Checklist

### Before Deployment

- [ ] Set `NODE_ENV=production`
- [ ] Enable global rate limiting
- [ ] Configure production CORS origins
- [ ] Set strong JWT secrets (32+ chars)
- [ ] Enable HTTPS only
- [ ] Configure logging service
- [ ] Set up monitoring alerts
- [ ] Review all environment variables
- [ ] Test all security features
- [ ] Run security audit (`npm audit`)

### Environment Variables Required

```bash
# Required
NODE_ENV=production
JWT_ACCESS_SECRET=your-32-char-secret
JWT_REFRESH_SECRET=your-32-char-secret
DATABASE_URL=postgresql://...
FRONTEND_URL=https://yourdomain.com

# Optional but recommended
MOBILE_APP_URL=https://app.yourdomain.com
SENTRY_DSN=your-sentry-dsn
LOG_LEVEL=info
```

---

## 📊 Security Monitoring

### Key Metrics to Track

1. **Rate Limit Violations**
   - Frequency per IP
   - Most common endpoints targeted

2. **Failed Authentications**
   - Failed login attempts per IP
   - Account lockouts triggered

3. **Input Sanitization Triggers**
   - XSS attempts blocked
   - SQL injection attempts blocked

4. **Suspicious Patterns**
   - Multiple registrations from same IP
   - Rapid password reset requests
   - Unusual endpoint access

### Query Security Events

```sql
-- Recent critical events
SELECT * FROM security_events 
WHERE severity = 'CRITICAL'
ORDER BY created_at DESC 
LIMIT 20;

-- Failed logins by IP
SELECT ip_address, COUNT(*) as attempts
FROM security_events 
WHERE event_type = 'LOGIN_FAILED'
AND created_at > NOW() - INTERVAL '1 hour'
GROUP BY ip_address
ORDER BY attempts DESC;

-- Account lockouts today
SELECT COUNT(*) as lockouts
FROM security_events 
WHERE event_type = 'ACCOUNT_LOCKED'
AND created_at > CURRENT_DATE;
```

---

## 🚨 Incident Response

### If Rate Limit Abuse Detected

1. Check IP in security logs
2. Review user agent patterns
3. Add IP to blocklist if needed
4. Investigate affected endpoints
5. Document incident

### If SQL Injection Attempt Detected

1. Log attempt details (IP, payload)
2. Review validation rules
3. Check if Prisma queries are parameterized
4. Monitor for repeated attempts
5. Consider IP blocking

### If XSS Attempt Detected

1. Log attempt details
2. Review sanitization effectiveness
3. Check if payload reached database
4. Verify CSP headers working
5. Update sanitization rules if needed

---

## 🔧 Quick Fixes

### Bypass Rate Limiting (Development Only)

```javascript
// Comment out in server.js
// app.use(globalRateLimit);
```

### Allow Additional CORS Origins

```javascript
// In .env file
FRONTEND_URL=http://localhost:5173,https://preview.vercel.app,https://yourdomain.com
```

### Adjust Rate Limits

```javascript
// In middleware/security.js
export const authRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20, // Increase from 10
  // ...
});
```

---

## 📱 Contact

For security issues, contact: security@motolens.com

**Do NOT** disclose security vulnerabilities publicly.

---

**Last Updated**: February 5, 2026  
**Version**: 1.0  
**Status**: Production Ready ✅
