import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Paper,
  Title,
  Text,
  TextInput,
  PasswordInput,
  Button,
  Stack,
  Box,
  Transition,
  Divider,
} from '@mantine/core';
import { FiLogIn, FiAlertCircle, FiUser, FiLock } from 'react-icons/fi';
import { useAuth } from '../contexts/AuthContext';
import { BRAND_COLORS } from '../styles/theme';
import { MotoLensLogo } from '../components/MotoLensLogo';

/**
 * LoginPage Component
 *
 * Professional mobile-first login page for MotoLens
 * Clean, minimal design - Stripe/Linear inspired
 */
export default function LoginPage() {
  const { login, isAuthenticated } = useAuth();
  const navigate = useNavigate();

  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // Redirect if already authenticated
  useEffect(() => {
    if (isAuthenticated) {
      navigate('/');
    }
  }, [isAuthenticated, navigate]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!username.trim()) {
      setError('Username is required');
      return;
    }

    if (!password.trim()) {
      setError('Password is required');
      return;
    }

    setLoading(true);

    try {
      const success = await login(username, password);

      if (success) {
        navigate('/');
      } else {
        setError('Invalid username or password');
      }
    } catch {
      setError('Something went wrong. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box
      style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: `linear-gradient(135deg, #f4f4f5 0%, #ffffff 50%, #e0f2fe 100%)`,
        padding: '1.5rem',
      }}
    >
      <Container size="xs" w="100%" maw={400}>
        <Stack gap="xl">
          {/* Logo */}
          <Box ta="center">
            <MotoLensLogo size={80} />
            <Title
              order={1}
              c={BRAND_COLORS.carbonBlack}
              fw={700}
              ff="Inter"
              size="1.75rem"
              mt="md"
              style={{ letterSpacing: '-0.03em' }}
            >
              MotoLens
            </Title>
            <Text c={BRAND_COLORS.gunmetalGray} size="sm" ff="Inter" mt={4}>
              Vehicle Intelligence Platform
            </Text>
          </Box>

          {/* Login Card */}
          <Paper
            shadow="md"
            p="xl"
            radius="lg"
            style={{
              backgroundColor: 'white',
              border: '1px solid #e4e4e7',
            }}
          >
            <form onSubmit={handleSubmit}>
              <Stack gap="md">
                {/* Error Message */}
                <Transition
                  mounted={!!error}
                  transition="slide-down"
                  duration={200}
                  timingFunction="ease"
                >
                  {styles => (
                    <Paper
                      p="sm"
                      radius="md"
                      style={{
                        ...styles,
                        backgroundColor: '#fef2f2',
                        border: '1px solid #fecaca',
                      }}
                    >
                      <Box style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                        <FiAlertCircle size={16} color="#dc2626" />
                        <Text size="sm" ff="Inter" c="#dc2626" fw={500}>
                          {error}
                        </Text>
                      </Box>
                    </Paper>
                  )}
                </Transition>

                {/* Username Input */}
                <TextInput
                  placeholder="Username"
                  value={username}
                  onChange={e => setUsername(e.target.value)}
                  size="md"
                  leftSection={<FiUser size={18} color={BRAND_COLORS.gunmetalGray} />}
                  styles={{
                    input: {
                      fontFamily: 'Inter',
                      fontSize: '0.95rem',
                      backgroundColor: '#fafafa',
                      border: '1px solid #e4e4e7',
                      borderRadius: '10px',
                      height: '48px',
                      '&:focus': {
                        borderColor: BRAND_COLORS.electricBlue,
                        backgroundColor: 'white',
                      },
                      '&::placeholder': {
                        color: '#a1a1aa',
                      },
                    },
                  }}
                  disabled={loading}
                />

                {/* Password Input */}
                <PasswordInput
                  placeholder="Password"
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  size="md"
                  leftSection={<FiLock size={18} color={BRAND_COLORS.gunmetalGray} />}
                  styles={{
                    input: {
                      fontFamily: 'Inter',
                      fontSize: '0.95rem',
                      backgroundColor: '#fafafa',
                      border: '1px solid #e4e4e7',
                      borderRadius: '10px',
                      height: '48px',
                      '&:focus': {
                        borderColor: BRAND_COLORS.electricBlue,
                        backgroundColor: 'white',
                      },
                      '&::placeholder': {
                        color: '#a1a1aa',
                      },
                    },
                    innerInput: {
                      height: '48px',
                    },
                  }}
                  disabled={loading}
                />

                {/* Login Button */}
                <Button
                  type="submit"
                  fullWidth
                  size="md"
                  loading={loading}
                  rightSection={!loading && <FiLogIn size={18} />}
                  style={{
                    height: '48px',
                    backgroundColor: BRAND_COLORS.electricBlue,
                    fontFamily: 'Inter',
                    fontWeight: 600,
                    fontSize: '0.95rem',
                    borderRadius: '10px',
                    transition: 'all 150ms ease',
                  }}
                  styles={{
                    root: {
                      '&:hover': {
                        backgroundColor: '#0284c7',
                        transform: 'translateY(-1px)',
                        boxShadow: '0 4px 12px rgba(14, 165, 233, 0.4)',
                      },
                      '&:active': {
                        transform: 'translateY(0)',
                      },
                    },
                  }}
                >
                  Sign In
                </Button>

                <Divider
                  my="xs"
                  label={
                    <Text size="xs" c="dimmed" ff="Inter">
                      Secure authentication
                    </Text>
                  }
                  labelPosition="center"
                />

                {/* Footer text inside card */}
                <Text size="xs" c="dimmed" ta="center" ff="Inter">
                  Professional diagnostic tools for mechanics
                </Text>
              </Stack>
            </form>
          </Paper>

          {/* Version/Copyright */}
          <Text size="xs" c="dark.6" ta="center" ff="Inter">
            MotoLens v1.0 • German Vehicle Specialist
          </Text>
        </Stack>
      </Container>
    </Box>
  );
}
