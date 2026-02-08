import { createContext, useContext, useState } from 'react';
import type { ReactNode } from 'react';

/**
 * German Car Medic Authentication Context
 *
 * Dummy authentication system for MVP
 * Hardcoded credentials: admin/admin
 *
 * WARNING: This is NOT production-ready. Replace with proper JWT/OAuth before production.
 */

// LocalStorage key for auth state persistence
const AUTH_STORAGE_KEY = 'germancarmedic_auth';

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

// Helper function to get initial auth state from localStorage
const getInitialAuthState = (): { isAuthenticated: boolean; username: string | null } => {
  try {
    const storedAuth = localStorage.getItem(AUTH_STORAGE_KEY);
    if (storedAuth) {
      const authData = JSON.parse(storedAuth);
      if (authData.isAuthenticated && authData.username) {
        return { isAuthenticated: true, username: authData.username };
      }
    }
  } catch (error) {
    console.error('Failed to parse stored auth data:', error);
    localStorage.removeItem(AUTH_STORAGE_KEY);
  }
  return { isAuthenticated: false, username: null };
};

export function AuthProvider({ children }: { children: ReactNode }) {
  const initialState = getInitialAuthState();
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(initialState.isAuthenticated);
  const [username, setUsername] = useState<string | null>(initialState.username);

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
