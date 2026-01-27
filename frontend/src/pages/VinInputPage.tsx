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
  Drawer,
  Divider,
  rem,
} from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { FiLogOut, FiInfo, FiArrowRight, FiMenu } from 'react-icons/fi';
import { MdDirectionsCar } from 'react-icons/md';

import { useAuth } from '../contexts/AuthContext';
import { validateVin, formatVin } from '../utils/vinValidator';
import { decodeVIN } from '../services/vehicleService';
import { BRAND_COLORS, TYPOGRAPHY } from '../styles/theme';
import { GermanCarMedicLogo } from '../components/GermanCarMedicLogo';

export default function VinInputPage() {
  const [vin, setVin] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [menuOpened, setMenuOpened] = useState(false);

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
      {/* Header/Navbar with Mobile Menu */}
      <Paper
        radius={0}
        p="sm"
        style={{
          backgroundColor: BRAND_COLORS.white,
          borderBottom: '1px solid #e4e4e7',
        }}
      >
        <Group justify="space-between" h={48}>
          {/* Logo Section */}
          <Group gap="xs">
            <MdDirectionsCar size={28} style={{ color: BRAND_COLORS.electricBlue }} />
            <Title
              order={3}
              style={{
                color: BRAND_COLORS.carbonBlack,
                fontFamily: 'Inter',
                fontSize: rem(24),
                fontWeight: 600,
              }}
            >
              German Car Medic
            </Title>
          </Group>

          {/* Mobile Menu Button */}
          <ActionIcon
            variant="subtle"
            color="blue"
            size="lg"
            onClick={() => setMenuOpened(true)}
            title="Menu"
          >
            <FiMenu size={24} />
          </ActionIcon>
        </Group>
      </Paper>

      {/* Mobile Sidebar Menu */}
      <Drawer
        opened={menuOpened}
        onClose={() => setMenuOpened(false)}
        title="Menu"
        padding="md"
        size="xs"
        position="right"
        styles={{
          header: {
            backgroundColor: BRAND_COLORS.white,
            borderBottom: '1px solid #e4e4e7',
          },
          title: {
            fontFamily: TYPOGRAPHY.fontFamily,
            fontWeight: 600,
            color: BRAND_COLORS.carbonBlack,
          },
          content: {
            backgroundColor: BRAND_COLORS.white,
          },
        }}
      >
        <Stack gap="md">
          {/* User Info */}
          <Paper
            p="md"
            radius="md"
            style={{ backgroundColor: '#f9fafb', border: '1px solid #e5e7eb' }}
          >
            <Text size="sm" c="dimmed" ff={TYPOGRAPHY.fontFamily}>
              Logged in as
            </Text>
            <Text size="lg" fw={600} c="dark" ff={TYPOGRAPHY.fontFamily}>
              {username}
            </Text>
          </Paper>

          <Divider />

          {/* Logout Button */}
          <Button
            fullWidth
            color="red"
            variant="light"
            leftSection={<FiLogOut size={18} />}
            onClick={() => {
              handleLogout();
              setMenuOpened(false);
            }}
            style={{
              fontFamily: TYPOGRAPHY.fontFamily,
              fontWeight: 500,
            }}
          >
            Sign Out
          </Button>
        </Stack>
      </Drawer>

      {/* Main content */}
      <Container
        size="sm"
        py="md"
        px="md"
        style={{
          minHeight: 'calc(100dvh - 48px)',
          display: 'flex',
          alignItems: 'flex-start',
          paddingTop: rem(16),
        }}
      >
        {/* Main VIN Input Card */}
        <Paper
          shadow="md"
          p="lg"
          radius="md"
          withBorder
          style={{
            backgroundColor: BRAND_COLORS.white,
            borderColor: '#e4e4e7',
          }}
        >
          <Stack gap="md">
            {/* Title */}
            <div style={{ textAlign: 'center' }}>
              {/* German Car Medic Logo - Larger with minimal margin */}
              <div style={{ marginBottom: rem(4) }}>
                <GermanCarMedicLogo size={220} />
              </div>

              <Title
                order={2}
                c={BRAND_COLORS.carbonBlack}
                fw={600}
                ff="Inter"
                size="1.3rem"
                mb="xs"
                style={{
                  margin: '0 auto 0.25rem auto',
                  whiteSpace: 'nowrap',
                }}
              >
                German Car Medic
              </Title>

              {/* <Text
                size="sm"
                c={BRAND_COLORS.electricBlue}
                fw={500}
                ff="Inter"
                mb="xs"
                style={{
                  fontStyle: 'italic',
                  margin: '0 auto 0.75rem auto',
                }}
              >
                Reliability meets Expertise
              </Text> */}

              <Text size="sm" style={{ color: BRAND_COLORS.gunmetalGray, lineHeight: 1.45 }}>
                Enter a 17-character VIN to decode vehicle information
              </Text>
            </div>

            {/* VIN Input */}
            <TextInput
              label="Vehicle Identification Number"
              placeholder="17-character VIN"
              value={vin}
              onChange={e => handleVinChange(e.target.value)}
              size="md"
              maxLength={17}
              styles={{
                label: {
                  color: BRAND_COLORS.carbonBlack,
                  fontFamily: TYPOGRAPHY.fontFamily,
                  fontWeight: 600,
                },
                input: {
                  fontFamily: TYPOGRAPHY.fontMono,
                  fontSize: rem(15),
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
              size="md"
              variant="filled"
              color="blue.4"
              onClick={() => handleSubmit()}
              disabled={vin.length !== 17 || loading}
              style={{
                backgroundColor: BRAND_COLORS.electricBlue,
                color: BRAND_COLORS.white,
                fontFamily: TYPOGRAPHY.fontFamily,
                fontWeight: 600,
                height: rem(52),
              }}
              rightSection={
                loading ? (
                  <Loader size="sm" color="white" />
                ) : (
                  <FiArrowRight size={20} color="white" />
                )
              }
            >
              {loading ? 'Decoding VIN...' : 'Decode VIN'}
            </Button>

            {/* Info Section */}
            <Paper
              p="sm"
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
              <Text size="sm" style={{ color: BRAND_COLORS.carbonBlack, lineHeight: 1.45 }}>
                BMW, Audi, Mercedes-Benz, Volkswagen, Porsche and other German vehicles
              </Text>
            </Paper>
          </Stack>
        </Paper>
      </Container>
    </div>
  );
}
