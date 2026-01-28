import { createContext, useContext, useState, useEffect } from 'react';
import type { ReactNode } from 'react';

/**
 * MotoLens Authentication Context
 *
 * Dummy authentication system for MVP
 * Hardcoded credentials: admin/admin
 *
 * WARNING: This is NOT production-ready. Replace with proper JWT/OAuth before production.
 */

// LocalStorage key for auth state persistence
const AUTH_STORAGE_KEY = 'motolens_auth';

// Hardcoded credentials for MVP (DO NOT use in production)
const VALID_CREDENTIALS = {
  username: 'admin',
  password: 'admin',
};

interface AuthContextType {
  isAuthenticated: boolean;
  login: (username: string, password: string) => Promise<boolean>;
  logout: () => void;
  username: string | null;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const [username, setUsername] = useState<string | null>(null);

  // Initialize auth state from localStorage on mount
  useEffect(() => {
    const storedAuth = localStorage.getItem(AUTH_STORAGE_KEY);
    if (storedAuth) {
      try {
        const authData = JSON.parse(storedAuth);
        if (authData.isAuthenticated && authData.username) {
          setIsAuthenticated(true);
          setUsername(authData.username);
        }
      } catch (error) {
        console.error('Failed to parse stored auth data:', error);
        localStorage.removeItem(AUTH_STORAGE_KEY);
      }
    }
  }, []);

  /**
   * Login function with dummy authentication
   * @param username - Username (must be 'admin')
   * @param password - Password (must be 'admin')
   * @returns Promise<boolean> - true if login successful, false otherwise
   */
  const login = async (username: string, password: string): Promise<boolean> => {
    // Simulate API delay (realistic UX)
    await new Promise(resolve => setTimeout(resolve, 500));

    // Validate credentials
    if (username === VALID_CREDENTIALS.username && password === VALID_CREDENTIALS.password) {
      // Set authenticated state
      setIsAuthenticated(true);
      setUsername(username);

      // Persist to localStorage
      const authData = {
        isAuthenticated: true,
        username,
        timestamp: new Date().toISOString(),
      };
      localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(authData));

      return true;
    }

    return false;
  };

  /**
   * Logout function
   * Clears authentication state and removes from localStorage
   */
  const logout = () => {
    setIsAuthenticated(false);
    setUsername(null);
    localStorage.removeItem(AUTH_STORAGE_KEY);
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, login, logout, username }}>
      {children}
    </AuthContext.Provider>
  );
}

/**
 * Custom hook to use auth context
 * Must be used within AuthProvider
 *
 * @example
 * const { isAuthenticated, login, logout } = useAuth();
 */
export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
