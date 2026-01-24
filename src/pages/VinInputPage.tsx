import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Paper,
  Title,
  Text,
  TextInput,
  Button,
  Stack,
  Group,
  Alert,
  Loader,
  ActionIcon,
  rem,
} from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { FiLogOut, FiInfo, FiArrowRight } from 'react-icons/fi';
import { MdDirectionsCar } from 'react-icons/md';

import { useAuth } from '../contexts/AuthContext';
import { validateVin, formatVin } from '../utils/vinValidator';
import { decodeVIN } from '../services/vehicleService';
import { BRAND_COLORS, TYPOGRAPHY } from '../styles/theme';
import { MotoLensLogo } from '../components/MotoLensLogo';

export default function VinInputPage() {
  const [vin, setVin] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const { logout, username } = useAuth();
  const navigate = useNavigate();

  const handleVinChange = (value: string) => {
    // Format and uppercase the input
    const formatted = formatVin(value);
    setVin(formatted);

    // Clear error when user starts typing
    if (error) {
      setError(null);
    }
  };

  const handleSubmit = async (submitVin: string = vin) => {
    // Validate VIN
    const validation = validateVin(submitVin);
    if (!validation.valid) {
      setError(validation.error || 'Invalid VIN');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      // Decode VIN through backend API
      const vehicleData = await decodeVIN(submitVin);

      // Show success notification
      notifications.show({
        title: 'VIN Decoded Successfully',
        message: `Found ${vehicleData.year} ${vehicleData.make} ${vehicleData.model}`,
        color: 'green',
        icon: <MdDirectionsCar size={16} />,
      });

      // Navigate to vehicle view with decoded data
      navigate(`/vehicle/${submitVin}`, {
        state: { vehicleData },
      });
    } catch (err) {
      const errorMessage =
        err instanceof Error ? err.message : 'Failed to decode VIN. Please try again.';
      setError(errorMessage);

      notifications.show({
        title: 'VIN Decoding Failed',
        message: errorMessage,
        color: 'red',
      });
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    logout();
    notifications.show({
      title: 'Logged Out',
      message: 'You have been successfully logged out',
      color: 'blue',
    });
  };

  return (
    <div
      style={{
        minHeight: '100vh',
        backgroundColor: '#fafafa',
        color: BRAND_COLORS.carbonBlack,
      }}
    >
      {/* Header with logout button */}
      <Paper
        radius={0}
        p="md"
        style={{
          backgroundColor: BRAND_COLORS.white,
          borderBottom: '1px solid #e4e4e7',
        }}
      >
        <Group justify="space-between" h={60}>
          <Group>
            <MdDirectionsCar size={24} style={{ color: BRAND_COLORS.electricBlue }} />
            <Title
              order={3}
              style={{
                color: BRAND_COLORS.carbonBlack,
                fontFamily: TYPOGRAPHY.fontFamily,
              }}
            >
              MotoLens
            </Title>
          </Group>

          <Group gap="sm">
            <Text size="sm" style={{ color: BRAND_COLORS.gunmetalGray }}>
              Welcome, {username}
            </Text>
            <ActionIcon
              variant="subtle"
              color="red"
              size="lg"
              onClick={handleLogout}
              title="Logout"
            >
              <FiLogOut size={18} />
            </ActionIcon>
          </Group>
        </Group>
      </Paper>

      {/* Main content */}
      <Container size="sm" py="xl" px="md">
        {/* Main VIN Input Card */}
        <Paper
          shadow="md"
          p="xl"
          radius="md"
          withBorder
          style={{
            backgroundColor: BRAND_COLORS.white,
            borderColor: '#e4e4e7',
          }}
        >
          <Stack gap="lg">
            {/* Title */}
            <div style={{ textAlign: 'center' }}>
              <Title
                order={1}
                style={{
                  color: BRAND_COLORS.carbonBlack,
                  fontFamily: TYPOGRAPHY.fontFamily,
                  marginBottom: rem(16),
                }}
              >
                VIN Decoder
              </Title>

              {/* MotoLens Logo */}
              <div style={{ marginBottom: rem(16) }}>
                <MotoLensLogo size={250} showCorners={false} />
              </div>

              <Text size="md" style={{ color: BRAND_COLORS.gunmetalGray }}>
                Enter a 17-character VIN to decode vehicle information
              </Text>
            </div>

            {/* VIN Input */}
            <TextInput
              label="Vehicle Identification Number (VIN)"
              placeholder="Enter 17-character VIN..."
              value={vin}
              onChange={e => handleVinChange(e.target.value)}
              size="lg"
              maxLength={17}
              styles={{
                label: {
                  color: BRAND_COLORS.carbonBlack,
                  fontFamily: TYPOGRAPHY.fontFamily,
                  fontWeight: 600,
                },
                input: {
                  fontFamily: TYPOGRAPHY.fontMono,
                  fontSize: rem(16),
                  letterSpacing: '0.05em',
                  backgroundColor: '#fafafa',
                  borderColor: '#e4e4e7',
                  color: BRAND_COLORS.carbonBlack,
                  '&::placeholder': {
                    color: '#a1a1aa',
                  },
                  '&:focus': {
                    borderColor: BRAND_COLORS.electricBlue,
                    backgroundColor: BRAND_COLORS.white,
                  },
                },
              }}
              rightSection={
                vin.length === 17 ? (
                  <Text size="xs" style={{ color: BRAND_COLORS.electricBlue }}>
                    ✓
                  </Text>
                ) : (
                  <Text size="xs" style={{ color: BRAND_COLORS.gunmetalGray }}>
                    {vin.length}/17
                  </Text>
                )
              }
            />

            {/* Error Alert */}
            {error && (
              <Alert color="red" variant="light" icon={<FiInfo size={16} />}>
                {error}
              </Alert>
            )}

            {/* Submit Button */}
            <Button
              size="lg"
              variant="filled"
              color="blue.4"
              onClick={() => handleSubmit()}
              disabled={vin.length !== 17 || loading}
              style={{
                backgroundColor: BRAND_COLORS.electricBlue,
                fontFamily: TYPOGRAPHY.fontFamily,
                fontWeight: 600,
                height: rem(56), // Large touch target for glove-friendly usage
              }}
              rightSection={
                loading ? <Loader size="sm" color="white" /> : <FiArrowRight size={20} />
              }
            >
              {loading ? 'Decoding VIN...' : 'Decode VIN'}
            </Button>

            {/* Info Section */}
            <Paper
              p="md"
              radius="sm"
              style={{
                backgroundColor: '#e0f2fe',
                border: '1px solid #bae6fd',
              }}
            >
              <Group gap="sm" mb="xs">
                <FiInfo size={16} style={{ color: BRAND_COLORS.electricBlue }} />
                <Text size="sm" fw={600} style={{ color: BRAND_COLORS.electricBlue }}>
                  Supported Brands
                </Text>
              </Group>
              <Text size="sm" style={{ color: BRAND_COLORS.carbonBlack }}>
                BMW, Audi, Mercedes-Benz, Volkswagen, Porsche and other German vehicles
              </Text>
            </Paper>
          </Stack>
        </Paper>
      </Container>
    </div>
  );
}
