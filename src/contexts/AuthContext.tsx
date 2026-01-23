import { createContext, useContext } from 'react';
import type { ReactNode } from 'react';

interface AuthContextType {
  isAuthenticated: boolean;
  login: (username: string, password: string) => Promise<boolean>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  // Auth logic will be implemented here
  const isAuthenticated = false;

  const login = async (username: string, password: string): Promise<boolean> => {
    // Dummy auth logic - to be implemented
    // TODO: Implement actual authentication
    console.log('Login attempt:', username, password);
    return false;
  };

  const logout = () => {
    // Logout logic - to be implemented
    // TODO: Implement logout functionality
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

// Custom hook to use auth context
export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
