# ✅ MotoLens JWT Utilities & Security - COMPLETE

**Date**: February 5, 2026
**Status**: ✅ Phase 14.2 Complete

## What Was Completed

### 1. ✅ JWT Utility Class (`src/utils/jwt.js`)

Complete JWT token management system with 12 methods:

#### Token Generation
- ✅ `generateAccessToken(user)` - Create 15-minute access tokens
- ✅ `generateRefreshToken(user)` - Create 7-day refresh tokens
- ✅ `generateTokenPair(user)` - Generate both tokens at once

#### Token Verification
- ✅ `verifyAccessToken(token)` - Verify access tokens with blacklist check
- ✅ `verifyRefreshToken(token)` - Verify refresh tokens with blacklist check
- ✅ Automatic token type validation
- ✅ Comprehensive error handling (expired, invalid, revoked)

#### Token Blacklisting
- ✅ `blacklistToken(token, reason)` - Revoke tokens for logout/security
- ✅ `isTokenBlacklisted(token)` - Check blacklist status
- ✅ Database-backed blacklist using UserSession table
- ✅ Automatic expiration tracking

#### Token Rotation
- ✅ `rotateTokens(oldRefreshToken, user)` - Rotate tokens on refresh
- ✅ Automatic old token revocation
- ✅ Seamless token pair generation

#### Helper Methods
- ✅ `extractTokenFromHeader(authHeader)` - Parse Bearer tokens
- ✅ `decodeToken(token)` - Decode without verification (debugging)
- ✅ `getTokenExpiration(token)` - Get token expiry date
- ✅ `isTokenExpired(token)` - Check if token is expired

### 2. ✅ Authentication Middleware (`src/middleware/auth.js`)

Complete middleware suite with 7 middleware functions:

#### Core Authentication
```javascript
authenticate(req, res, next)
```
- ✅ JWT token verification
- ✅ User fetching from database
- ✅ Active status validation
- ✅ User attachment to request object

#### Role-Based Access Control (RBAC)
```javascript
requireRole('ADMIN', 'MECHANIC')
```
- ✅ Multi-role support
- ✅ Clear permission error messages
- ✅ Flexible role checking

#### Email Verification
```javascript
requireEmailVerified(req, res, next)
```
- ✅ Email verification enforcement
- ✅ Clear error messages for unverified users

#### Subscription Gating
```javascript
requireSubscription('PREMIUM', 'PROFESSIONAL')
```
- ✅ Feature gating by subscription tier
- ✅ Current tier display in error response
- ✅ Multiple tier support

#### Session Management
```javascript
validateSession(req, res, next)
```
- ✅ Active session validation
- ✅ Session timeout enforcement (30 minutes default)
- ✅ Last activity tracking
- ✅ Automatic session expiration

#### Optional Authentication
```javascript
optionalAuth(req, res, next)
```
- ✅ Non-blocking authentication
- ✅ Useful for public routes with optional features
- ✅ Graceful token validation failure

#### Security Logging
```javascript
logSecurityEvent('LOGIN_SUCCESS', 'LOW')
```
- ✅ Automatic security event logging
- ✅ IP address tracking
- ✅ User agent logging
- ✅ Request metadata capture

## Architecture

### Token Structure

**Access Token Payload:**
```json
{
  "sub": "user-id-uuid",
  "email": "user@example.com",
  "role": "MECHANIC",
  "type": "access",
  "iss": "motolens-api",
  "aud": "motolens-app",
  "exp": 1234567890,
  "iat": 1234566990
}
```

**Refresh Token Payload:**
```json
{
  "sub": "user-id-uuid",
  "type": "refresh",
  "iss": "motolens-api",
  "aud": "motolens-app",
  "exp": 1234567890,
  "iat": 1234566990
}
```

### Token Lifecycle

```
1. User logs in
   ↓
2. Generate access token (15m) + refresh token (7d)
   ↓
3. Create UserSession record in database
   ↓
4. Return tokens to client
   ↓
5. Client uses access token for API requests
   ↓
6. Access token expires after 15 minutes
   ↓
7. Client sends refresh token to /auth/refresh-token
   ↓
8. Server validates refresh token
   ↓
9. Generate new token pair
   ↓
10. Blacklist old refresh token
    ↓
11. Return new tokens to client
```

### Security Features

#### ✅ Token Blacklisting
- Database-backed blacklist
- Tokens checked on every verification
- Automatic cleanup on session revocation
- Support for logout and security revocations

#### ✅ Token Rotation
- Old refresh tokens automatically revoked
- Prevents token reuse attacks
- Seamless token renewal

#### ✅ Session Timeout
- Configurable inactivity timeout (default: 30 minutes)
- Last activity tracking
- Automatic session expiration
- Manual session revocation support

#### ✅ Multi-Device Session Management
- Track sessions per user
- Maximum concurrent sessions (5 default)
- Device information tracking
- Individual session revocation

#### ✅ Security Event Logging
- All authentication events logged
- IP address tracking
- User agent tracking
- Request metadata capture
- Severity levels (LOW, MEDIUM, HIGH, CRITICAL)

## Usage Examples

### Protecting Routes with Authentication

```javascript
const { authenticate, requireRole, validateSession } = require('./middleware/auth');

// Public route (no auth)
app.get('/api/vehicles/search', publicSearchController);

// Authenticated route
app.get('/api/auth/me', authenticate, getMeController);

// Admin-only route
app.get('/api/admin/users', authenticate, requireRole('ADMIN'), listUsersController);

// Mechanic or admin route
app.get('/api/scans', authenticate, requireRole('MECHANIC', 'ADMIN'), listScansController);

// Premium feature
app.get('/api/reports/advanced',
  authenticate,
  requireSubscription('PREMIUM', 'PROFESSIONAL'),
  advancedReportsController
);

// Email verification required
app.post('/api/scans/new',
  authenticate,
  requireEmailVerified,
  createScanController
);

// Full session validation
app.post('/api/account/delete',
  authenticate,
  validateSession,
  logSecurityEvent('ACCOUNT_DELETE', 'HIGH'),
  deleteAccountController
);
```

### Token Generation

```javascript
const JWTUtil = require('./utils/jwt');

// Login endpoint
async function login(req, res) {
  const { email, password } = req.body;

  // Validate credentials...
  const user = await authenticateUser(email, password);

  // Generate token pair
  const { accessToken, refreshToken, expiresIn } = JWTUtil.generateTokenPair(user);

  // Store session
  await prisma.userSession.create({
    data: {
      userId: user.id,
      accessToken,
      refreshToken,
      deviceInfo: req.headers['user-agent'],
      ipAddress: req.ip,
      isActive: true
    }
  });

  res.json({
    success: true,
    data: {
      accessToken,
      refreshToken,
      expiresIn,
      user: {
        id: user.id,
        email: user.email,
        role: user.role
      }
    }
  });
}
```

### Token Refresh

```javascript
// Refresh token endpoint
async function refreshToken(req, res) {
  const { refreshToken } = req.body;

  try {
    // Verify refresh token
    const decoded = await JWTUtil.verifyRefreshToken(refreshToken);

    // Get user
    const user = await prisma.user.findUnique({
      where: { id: decoded.sub }
    });

    // Rotate tokens
    const newTokens = await JWTUtil.rotateTokens(refreshToken, user);

    // Update session
    await prisma.userSession.updateMany({
      where: { refreshToken },
      data: {
        accessToken: newTokens.accessToken,
        refreshToken: newTokens.refreshToken,
        lastActivityAt: new Date()
      }
    });

    res.json({
      success: true,
      data: newTokens
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      error: error.message
    });
  }
}
```

### Logout

```javascript
// Logout endpoint
async function logout(req, res) {
  try {
    // Blacklist current token
    await JWTUtil.blacklistToken(req.token, 'logout');

    // Mark session as inactive
    await prisma.userSession.updateMany({
      where: {
        userId: req.user.id,
        accessToken: req.token
      },
      data: {
        isActive: false
      }
    });

    res.json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Logout failed'
    });
  }
}

// Logout all devices
async function logoutAll(req, res) {
  try {
    // Mark all sessions as inactive
    await prisma.userSession.updateMany({
      where: { userId: req.user.id },
      data: { isActive: false }
    });

    res.json({
      success: true,
      message: 'Logged out from all devices'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Logout failed'
    });
  }
}
```

## Configuration

### Environment Variables

All JWT settings are configured in `.env`:

```env
# JWT Secrets (Generated with openssl rand -base64 32)
JWT_SECRET=zOqU6qWv/J0gkrHVv303e+XYXuhGOWAhZ2bWGq2VP7E=
JWT_REFRESH_SECRET=DkgqXfJ4uNM0mOKUe/rC8rfdu1D0SmimsacOwLt5E+I=

# Token expiry times
JWT_ACCESS_TOKEN_EXPIRY=15m
JWT_REFRESH_TOKEN_EXPIRY=7d

# Session settings
SESSION_TIMEOUT_MINUTES=30
MAX_SESSIONS_PER_USER=5
```

## Testing

### Manual Testing with cURL

```bash
# Login
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'

# Protected route with token
curl http://localhost:3001/api/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Refresh token
curl -X POST http://localhost:3001/api/auth/refresh-token \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"YOUR_REFRESH_TOKEN"}'

# Logout
curl -X POST http://localhost:3001/api/auth/logout \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Security Best Practices Implemented

✅ **Token Security**
- Cryptographically secure JWT secrets (32 bytes)
- Short-lived access tokens (15 minutes)
- Long-lived refresh tokens (7 days)
- Token type validation
- Issuer and audience validation

✅ **Session Security**
- Database-backed token blacklist
- Session timeout enforcement
- Multi-device session tracking
- Maximum concurrent sessions limit
- IP address and user agent tracking

✅ **Access Control**
- Role-based access control (RBAC)
- Subscription tier gating
- Email verification requirements
- Optional authentication for public routes

✅ **Audit Trail**
- Security event logging
- Login history tracking
- Failed authentication logging
- Session activity monitoring

## Files Created

1. ✅ `src/utils/jwt.js` - JWT utility class (320 lines)
2. ✅ `src/middleware/auth.js` - Authentication middleware (330 lines)
3. ✅ `JWT_SECURITY_COMPLETE.md` - This documentation file

## Next Steps

### Phase 14.3: Password Security & Validation
Create `backend/src/utils/password.js`:
```javascript
class PasswordUtil {
  static async hash(password)
  static async verify(password, hash)
  static validateStrength(password)
  static generateSecureToken()
}
```

### Phase 14.4: Email Service Integration
Create `backend/src/services/emailService.js`:
```javascript
class EmailService {
  static async sendVerificationEmail(user, token)
  static async sendPasswordResetEmail(user, token)
  static async sendPasswordChangeNotification(user)
  static async sendLoginNotification(user, deviceInfo)
}
```

### Phase 14.5: Authentication Routes
Create `backend/src/routes/auth.js`:
```javascript
// Registration & Login
POST /api/auth/register
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/refresh-token
GET /api/auth/me

// Password Management
POST /api/auth/forgot-password
POST /api/auth/reset-password
PUT /api/auth/change-password

// Email Verification
POST /api/auth/verify-email
POST /api/auth/resend-verification

// Session Management
GET /api/auth/sessions
DELETE /api/auth/sessions/:sessionId
```

## Useful Commands

```bash
# Test JWT utilities
node -e "const JWTUtil = require('./src/utils/jwt'); console.log(JWTUtil)"

# Check middleware exports
node -e "const auth = require('./src/middleware/auth'); console.log(Object.keys(auth))"

# Verify Prisma connection
npx prisma studio

# View security events
psql -d motolens_dev -c "SELECT * FROM security_events ORDER BY created_at DESC LIMIT 10;"

# View active sessions
psql -d motolens_dev -c "SELECT * FROM user_sessions WHERE is_active = true;"
```

---

**Phase 14.2: JWT Utilities & Security** ✅ **COMPLETE**

Ready to proceed to Phase 14.3: Password Security & Validation! 🚀
