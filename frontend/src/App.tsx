import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './contexts/AuthContext';
import LoginPage from './pages/LoginPage';
import VinInputPage from './pages/VinInputPage';
import VehicleViewPage from './pages/VehicleViewPage';
import Vehicle360Test from './pages/Vehicle360Test';
import PartScannerPage from './pages/PartScannerPage';

/**
 * App Component
 * Main application with routing
 */
function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route
          path="/"
          element={
            <ProtectedRoute>
              <VinInputPage />
            </ProtectedRoute>
          }
        />
        <Route
          path="/vehicle/:vin"
          element={
            <ProtectedRoute>
              <VehicleViewPage />
            </ProtectedRoute>
          }
        />
        <Route
          path="/scan"
          element={
            <ProtectedRoute>
              <PartScannerPage />
            </ProtectedRoute>
          }
        />
        <Route
          path="/test-360"
          element={
            <ProtectedRoute>
              <Vehicle360Test />
            </ProtectedRoute>
          }
        />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

/**
 * ProtectedRoute Component
 * Redirects to login if not authenticated
 */
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { isAuthenticated } = useAuth();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return <>{children}</>;
}

export default App;
