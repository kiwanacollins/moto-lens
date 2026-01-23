import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { MantineProvider } from '@mantine/core';
import '@mantine/core/styles.css';
import './index.css';
import App from './App.tsx';
import { theme } from './styles/theme';
import { AuthProvider } from './contexts/AuthContext';

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <MantineProvider theme={theme} defaultColorScheme="dark">
      <AuthProvider>
        <App />
      </AuthProvider>
    </MantineProvider>
  </StrictMode>
);
