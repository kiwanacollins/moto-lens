import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Container,
  Paper,
  Title,
  Text,
  Stack,
  Group,
  Button,
  Loader,
  Alert,
  Divider,
  List,
  Box,
  Transition
} from '@mantine/core';
import { MdArrowBack, MdLogout, MdDirectionsCar } from 'react-icons/md';
import { FiInfo } from 'react-icons/fi';
import { useAuth } from '../contexts/AuthContext';
import { decodeVIN, getVehicleSummary } from '../services/vehicleService';
import type { VehicleData, VehicleSummary } from '../types/vehicle';

export default function VehicleViewPage() {
  const { vin } = useParams<{ vin: string }>();
  const navigate = useNavigate();
  const { logout } = useAuth();

  const [vehicleData, setVehicleData] = useState<VehicleData | null>(null);
  const [vehicleSummary, setVehicleSummary] = useState<VehicleSummary | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!vin) {
      navigate('/');
      return;
    }

    loadVehicleData();
  }, [vin, navigate]);

  const loadVehicleData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Decode VIN first
      const vehicleInfo = await decodeVIN(vin!);
      setVehicleData(vehicleInfo);

      // Get AI summary
      const summary = await getVehicleSummary(vehicleInfo);
      setVehicleSummary(summary);

    } catch (err) {
      console.error('Error loading vehicle data:', err);
      setError(err instanceof Error ? err.message : 'Failed to load vehicle information');
    } finally {
      setLoading(false);
    }
  };

  const handleBackClick = () => {
    navigate('/');
  };

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  if (loading) {
    return (
      <Container size="lg" py="xl">
        <Paper shadow="md" p="xl" radius="md" withBorder bg="white">
          <Stack align="center" gap="md">
            <Loader size="lg" color="blue.4" />
            <Text size="lg" c="dark.9" ff="Inter" fw={500}>
              Loading vehicle information...
            </Text>
          </Stack>
        </Paper>
      </Container>
    );
  }

  if (error) {
    return (
      <Container size="lg" py="xl">
        <Paper shadow="md" p="xl" radius="md" withBorder bg="white">
          <Alert
            icon={<FiInfo size={16} />}
            color="red"
            title="Error Loading Vehicle"
            mb="lg"
          >
            {error}
          </Alert>
          <Group justify="center">
            <Button
              leftSection={<MdArrowBack size={20} />}
              variant="filled"
              color="blue.4"
              size="md"
              onClick={handleBackClick}
            >
              Try Another VIN
            </Button>
          </Group>
        </Paper>
      </Container>
    );
  }

  return (
    <Container size="lg" py="xl">
      <Transition mounted={!loading} transition="fade" duration={300}>
        {(styles) => (
          <div style={styles}>
            {/* Header with navigation */}
            <Group justify="space-between" mb="xl">
              <Button
                leftSection={<MdArrowBack size={20} />}
                variant="subtle"
                color="blue.4"
                size="md"
                onClick={handleBackClick}
                ff="Inter"
                fw={500}
              >
                New VIN
              </Button>

              <Button
                leftSection={<MdLogout size={20} />}
                variant="subtle"
                color="dark.6"
                size="md"
                onClick={handleLogout}
                ff="Inter"
                fw={500}
              >
                Logout
              </Button>
            </Group>

            <Stack gap="lg">
              {vehicleData && (
                <>
                  {/* Vehicle Metadata Card */}
                  <Paper shadow="md" p="xl" radius="md" withBorder bg="white">
                    {/* Vehicle Icon and Title */}
                    <Group mb="lg" align="center">
                      <Box
                        p="md"
                        style={{
                          backgroundColor: '#0ea5e9',
                          borderRadius: '8px',
                        }}
                      >
                        <MdDirectionsCar size={24} color="white" />
                      </Box>
                      <div>
                        <Title
                          order={2}
                          ff="Inter"
                          fw={600}
                          c="dark.9"
                          size="xl"
                        >
                          {vehicleData.year} {vehicleData.make} {vehicleData.model}
                        </Title>
                        {vehicleData.trim && (
                          <Text size="md" c="dark.6" ff="Inter" fw={500}>
                            {vehicleData.trim}
                          </Text>
                        )}
                      </div>
                    </Group>

                    <Divider mb="lg" color="zinc.2" />

                    {/* Technical Specifications */}
                    <Stack gap="md">
                      <Group justify="space-between" wrap="wrap">
                        <div>
                          <Text size="sm" c="dark.6" ff="Inter" fw={500} tt="uppercase">
                            Engine
                          </Text>
                          <Text size="lg" c="dark.9" ff="Inter" fw={600}>
                            {vehicleData.engine}
                          </Text>
                        </div>
                        <div>
                          <Text size="sm" c="dark.6" ff="Inter" fw={500} tt="uppercase">
                            Body Type
                          </Text>
                          <Text size="lg" c="dark.9" ff="Inter" fw={600}>
                            {vehicleData.bodyType}
                          </Text>
                        </div>
                      </Group>

                      <Group justify="space-between" wrap="wrap">
                        <div>
                          <Text size="sm" c="dark.6" ff="Inter" fw={500} tt="uppercase">
                            Manufacturer
                          </Text>
                          <Text size="lg" c="dark.9" ff="Inter" fw={600}>
                            {vehicleData.manufacturer}
                          </Text>
                        </div>
                      </Group>

                      <Divider color="zinc.2" />

                      {/* VIN Display */}
                      <div>
                        <Text size="sm" c="dark.6" ff="Inter" fw={500} tt="uppercase" mb="xs">
                          Vehicle Identification Number
                        </Text>
                        <Text
                          size="lg"
                          ff="JetBrains Mono"
                          fw={600}
                          c="blue.4"
                          style={{
                            letterSpacing: '0.5px',
                            fontSize: '18px',
                          }}
                        >
                          {vehicleData.vin}
                        </Text>
                      </div>
                    </Stack>
                  </Paper>

                  {/* Vehicle Summary Card */}
                  {vehicleSummary && (
                    <Paper shadow="md" p="xl" radius="md" withBorder bg="white">
                      <Group mb="lg" align="center">
                        <Box
                          p="md"
                          style={{
                            backgroundColor: '#52525b',
                            borderRadius: '8px',
                          }}
                        >
                          <FiInfo size={20} color="white" />
                        </Box>
                        <Title
                          order={3}
                          ff="Inter"
                          fw={600}
                          c="dark.9"
                          size="lg"
                        >
                          Vehicle Information
                        </Title>
                      </Group>

                      <List
                        spacing="sm"
                        size="md"
                        withPadding
                        styles={{
                          item: {
                            fontSize: '16px',
                            lineHeight: '1.6',
                            color: '#0a0a0a',
                            fontFamily: 'Inter',
                          },
                          itemWrapper: {
                            alignItems: 'flex-start',
                          },
                        }}
                      >
                        {vehicleSummary.bulletPoints.map((point, index) => (
                          <List.Item key={index}>
                            {point}
                          </List.Item>
                        ))}
                      </List>
                    </Paper>
                  )}
                </>
              )}
            </Stack>
          </div>
        )}
      </Transition>
    </Container>
  );
}
