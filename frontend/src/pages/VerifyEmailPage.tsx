import { useEffect, useState } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import { Container, Paper, Title, Text, Button, Loader, Stack } from '@mantine/core';
import { FiCheckCircle, FiXCircle, FiMail } from 'react-icons/fi';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3001/api';

type VerificationStatus = 'loading' | 'success' | 'error';

export default function VerifyEmailPage() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const [status, setStatus] = useState<VerificationStatus>('loading');
  const [message, setMessage] = useState('');

  const token = searchParams.get('token');

  useEffect(() => {
    if (!token) {
      setStatus('error');
      setMessage('No verification token found. Please check your email link.');
      return;
    }

    const verifyEmail = async () => {
      try {
        const response = await fetch(`${API_BASE_URL}/auth/verify-email`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ token }),
        });

        const data = await response.json();

        if (response.ok && data.success) {
          setStatus('success');
          setMessage(data.message || 'Your email has been verified successfully!');
        } else {
          setStatus('error');
          setMessage(data.message || data.error || 'Verification failed. The link may have expired.');
        }
      } catch {
        setStatus('error');
        setMessage('Unable to reach the server. Please try again later.');
      }
    };

    verifyEmail();
  }, [token]);

  return (
    <Container size={420} py={80}>
      <Paper radius="md" p="xl" withBorder shadow="sm">
        <Stack align="center" gap="md">
          {status === 'loading' && (
            <>
              <Loader size="lg" color="blue" />
              <Title order={3} ta="center">Verifying your email...</Title>
              <Text c="dimmed" ta="center">Please wait while we verify your email address.</Text>
            </>
          )}

          {status === 'success' && (
            <>
              <FiCheckCircle size={56} color="#40c057" />
              <Title order={3} ta="center">Email Verified!</Title>
              <Text c="dimmed" ta="center">{message}</Text>
              <Text c="dimmed" ta="center" size="sm">
                You can now sign in to your account with full access.
              </Text>
              <Button fullWidth mt="sm" onClick={() => navigate('/login')}>
                Go to Sign In
              </Button>
            </>
          )}

          {status === 'error' && (
            <>
              <FiXCircle size={56} color="#fa5252" />
              <Title order={3} ta="center">Verification Failed</Title>
              <Text c="dimmed" ta="center">{message}</Text>
              <Button fullWidth variant="light" mt="sm" onClick={() => navigate('/login')}>
                Go to Sign In
              </Button>
            </>
          )}

          <Text c="dimmed" size="xs" ta="center" mt="md">
            <FiMail size={14} style={{ verticalAlign: 'middle', marginRight: 4 }} />
            German Car Medic
          </Text>
        </Stack>
      </Paper>
    </Container>
  );
}
