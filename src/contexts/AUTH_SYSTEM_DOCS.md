# MotoLens Authentication System Documentation

## Overview

The MotoLens authentication system is a **dummy authentication** implementation for MVP purposes. It provides basic login/logout functionality with hardcoded credentials and localStorage persistence.

⚠️ **WARNING**: This is NOT production-ready. Replace with proper JWT/OAuth2 authentication before production deployment.

## Components

### 1. AuthContext (`src/contexts/AuthContext.tsx`)

The main authentication context using React Context API.

**Features:**
- ✅ Hardcoded credentials (admin/admin)
- ✅ localStorage persistence
- ✅ Automatic state restoration on page reload
- ✅ Type-safe with TypeScript
- ✅ Custom `useAuth` hook

**API:**

```tsx
interface AuthContextType {
  isAuthenticated: boolean;      // Current auth state
  username: string | null;       // Current username (null if not authenticated)
  login: (username: string, password: string) => Promise<boolean>;
  logout: () => void;
}
```

### 2. AuthProvider (`src/contexts/AuthContext.tsx`)

Wraps the application to provide authentication context.

**Usage:**

```tsx
// In main.tsx
import { AuthProvider } from './contexts/AuthContext';

<AuthProvider>
  <App />
</AuthProvider>
```

### 3. useAuth Hook

Custom hook to access authentication context from any component.

**Usage:**

```tsx
import { useAuth } from '@/contexts/AuthContext';

function MyComponent() {
  const { isAuthenticated, login, logout, username } = useAuth();
  
  // Use authentication state and methods
}
```

## Hardcoded Credentials

**For MVP testing only:**

```typescript
Username: admin
Password: admin
```

## LocalStorage Persistence

**Key:** `motolens_auth`

**Stored Data Structure:**

```json
{
  "isAuthenticated": true,
  "username": "admin",
  "timestamp": "2026-01-23T19:30:00.000Z"
}
```

**Behavior:**
- ✅ Auth state persists across page reloads
- ✅ Auth state persists across browser sessions
- ✅ Cleared on logout
- ✅ Automatically restored on app initialization

## Authentication Flow

### Login Flow

1. User enters username and password
2. `login()` function validates against hardcoded credentials
3. 500ms simulated delay (realistic UX)
4. If valid:
   - Sets `isAuthenticated` to `true`
   - Stores username
   - Saves to localStorage
   - Returns `true`
5. If invalid:
   - Returns `false`
   - No state changes

### Logout Flow

1. User clicks logout
2. `logout()` function called
3. Clears authentication state
4. Removes localStorage entry
5. User redirected to login (handled by router)

### Auto-Restore Flow

1. App initializes
2. AuthProvider checks localStorage for `motolens_auth`
3. If found and valid:
   - Parses stored data
   - Restores authentication state
   - User stays logged in
4. If not found or invalid:
   - User remains logged out

## Usage Examples

### Basic Login Component

```tsx
import { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';

function LoginForm() {
  const { login } = useAuth();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const success = await login(username, password);
    
    if (!success) {
      setError('Invalid credentials');
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <input 
        value={username} 
        onChange={(e) => setUsername(e.target.value)} 
      />
      <input 
        type="password"
        value={password} 
        onChange={(e) => setPassword(e.target.value)} 
      />
      {error && <p>{error}</p>}
      <button type="submit">Login</button>
    </form>
  );
}
```

### Protected Component

```tsx
import { useAuth } from '@/contexts/AuthContext';
import { Navigate } from 'react-router-dom';

function ProtectedPage() {
  const { isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return <div>Protected Content</div>;
}
```

### Logout Button

```tsx
import { useAuth } from '@/contexts/AuthContext';
import { Button } from '@mantine/core';
import { FiLogOut } from 'react-icons/fi';

function LogoutButton() {
  const { logout } = useAuth();

  return (
    <Button 
      color="red" 
      onClick={logout}
      leftSection={<FiLogOut size={18} />}
    >
      Logout
    </Button>
  );
}
```

### Display Current User

```tsx
import { useAuth } from '@/contexts/AuthContext';
import { Badge } from '@mantine/core';

function UserBadge() {
  const { username, isAuthenticated } = useAuth();

  if (!isAuthenticated) return null;

  return (
    <Badge color="blue.4" variant="filled">
      {username}
    </Badge>
  );
}
```

## Testing

### Manual Testing

1. **Start dev server:**
   ```bash
   npm run dev
   ```

2. **Import AuthTest component:**
   ```tsx
   import { AuthTest } from './components/auth/AuthTest';
   
   function App() {
     return <AuthTest />;
   }
   ```

3. **Test scenarios:**
   - ✅ Login with correct credentials (admin/admin)
   - ✅ Login with wrong credentials
   - ✅ Logout
   - ✅ Reload page while logged in (should stay logged in)
   - ✅ Logout and reload (should stay logged out)
   - ✅ Check localStorage in DevTools

### Automated Testing (Future)

```tsx
import { renderHook, act } from '@testing-library/react';
import { AuthProvider, useAuth } from './AuthContext';

describe('AuthContext', () => {
  test('login with valid credentials', async () => {
    const { result } = renderHook(() => useAuth(), {
      wrapper: AuthProvider,
    });

    await act(async () => {
      const success = await result.current.login('admin', 'admin');
      expect(success).toBe(true);
      expect(result.current.isAuthenticated).toBe(true);
    });
  });

  test('login with invalid credentials', async () => {
    const { result } = renderHook(() => useAuth(), {
      wrapper: AuthProvider,
    });

    await act(async () => {
      const success = await result.current.login('wrong', 'wrong');
      expect(success).toBe(false);
      expect(result.current.isAuthenticated).toBe(false);
    });
  });
});
```

## Security Considerations

### ⚠️ Current Limitations (MVP Only)

- ❌ **No password hashing** - Plaintext comparison
- ❌ **No session expiration** - Stays logged in forever
- ❌ **No CSRF protection**
- ❌ **No rate limiting** - Brute force possible
- ❌ **No secure token** - Just localStorage flag
- ❌ **Hardcoded credentials** - Not configurable
- ❌ **Client-side only** - No server verification

### ✅ Production Requirements

Before production, implement:

1. **Backend Authentication:**
   - JWT tokens with proper signing
   - Refresh token mechanism
   - Secure HTTP-only cookies
   - Password hashing (bcrypt/argon2)

2. **Session Management:**
   - Token expiration (15-60 minutes)
   - Automatic token refresh
   - Logout on token expiration
   - "Remember me" functionality

3. **Security Features:**
   - CSRF tokens
   - Rate limiting (login attempts)
   - XSS protection
   - Input sanitization
   - Secure password requirements

4. **User Management:**
   - Database-backed user accounts
   - Password reset flow
   - Email verification
   - Multi-factor authentication (optional)

## Migration Path to Production Auth

### Step 1: Backend JWT Implementation

```typescript
// backend/auth.ts
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';

async function login(username: string, password: string) {
  const user = await db.users.findOne({ username });
  if (!user) return null;
  
  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) return null;
  
  const token = jwt.sign(
    { userId: user.id, username: user.username },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );
  
  return { token, user };
}
```

### Step 2: Frontend Token Storage

```typescript
// Use secure storage instead of plain localStorage
import { SecureStorage } from '@/utils/secureStorage';

const token = await loginAPI(username, password);
SecureStorage.setToken(token);
```

### Step 3: API Request Interceptor

```typescript
// Add token to all API requests
axios.interceptors.request.use((config) => {
  const token = SecureStorage.getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
```

## Troubleshooting

### Issue: Auth state not persisting

**Solution:** Check browser localStorage in DevTools
```javascript
// In browser console
localStorage.getItem('motolens_auth')
```

### Issue: useAuth throws error

**Solution:** Ensure component is wrapped in AuthProvider
```tsx
// main.tsx must have:
<AuthProvider>
  <App />
</AuthProvider>
```

### Issue: Login always fails

**Solution:** Verify credentials are exactly `admin/admin` (case-sensitive)

### Issue: Can't logout

**Solution:** Check if logout function is called correctly
```tsx
const { logout } = useAuth();
logout(); // Not logout('admin')
```

## File Locations

```
src/
├── contexts/
│   └── AuthContext.tsx          # Main auth context
├── components/
│   └── auth/
│       └── AuthTest.tsx         # Test component
└── main.tsx                     # AuthProvider integration
```

## API Reference

### `login(username: string, password: string): Promise<boolean>`

Attempts to authenticate with provided credentials.

**Parameters:**
- `username` - Username string
- `password` - Password string

**Returns:**
- `Promise<boolean>` - `true` if login successful, `false` otherwise

**Example:**
```tsx
const success = await login('admin', 'admin');
if (success) {
  // Login successful
} else {
  // Login failed
}
```

### `logout(): void`

Logs out current user and clears auth state.

**Example:**
```tsx
logout();
// User is now logged out
```

### `isAuthenticated: boolean`

Current authentication status.

**Example:**
```tsx
if (isAuthenticated) {
  return <ProtectedContent />;
}
return <LoginPage />;
```

### `username: string | null`

Current authenticated username, or `null` if not authenticated.

**Example:**
```tsx
<Text>Welcome, {username}!</Text>
```

---

## Summary

✅ **Complete** - Dummy authentication system ready for MVP  
✅ **Tested** - Works with localStorage persistence  
✅ **Documented** - Full usage guide and examples  
⚠️ **NOT Production-Ready** - Replace before production  

**Next Steps:**
1. Integrate with LoginPage component
2. Implement Protected Routes
3. Test on mobile devices
4. Plan production JWT migration
