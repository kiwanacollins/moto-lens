import { useEffect, useState, useCallback } from 'react';
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
  Box,
  Transition,
  ScrollArea,
} from '@mantine/core';
import { MdArrowBack, MdLogout } from 'react-icons/md';
import { FiInfo, FiCamera } from 'react-icons/fi';
import { useAuth } from '../contexts/AuthContext';
import { decodeVIN, getVehicleSummary } from '../services/vehicleService';
import type { VehicleData, VehicleSummary } from '../types/vehicle';
import Vehicle360Viewer from '../components/vehicle/Vehicle360Viewer';
import PartsGrid from '../components/parts/PartsGrid';

export default function VehicleViewPage() {
  const { vin } = useParams<{ vin: string }>();
  const navigate = useNavigate();
  const { logout } = useAuth();

  const [vehicleData, setVehicleData] = useState<VehicleData | null>(null);
  const [vehicleSummary, setVehicleSummary] = useState<VehicleSummary | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadVehicleData = useCallback(async () => {
    if (!vin) return;

    try {
      setLoading(true);
      setError(null);

      // Decode VIN first
      const vehicleInfo = await decodeVIN(vin);
      setVehicleData(vehicleInfo);

      // Check if VIN has validation issues but still returned data
      if (vehicleInfo.vinValid === false) {
        console.warn('VIN validation issues detected:', {
          vin,
          make: vehicleInfo.make,
          model: vehicleInfo.model,
          vinValid: vehicleInfo.vinValid
        });
      }

      // Get AI summary - use the original VIN from URL, not the potentially modified one from backend
      const summary = await getVehicleSummary({ ...vehicleInfo, vin: vin });
      setVehicleSummary(summary);
    } catch (err) {
      console.error('Error loading vehicle data:', err);
      setError(err instanceof Error ? err.message : 'Failed to load vehicle information');
    } finally {
      setLoading(false);
    }
  }, [vin]);

  useEffect(() => {
    if (!vin) {
      navigate('/');
      return;
    }

    loadVehicleData();
  }, [vin, navigate, loadVehicleData]);

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
            <Text size="sm" c="dark.6" ff="Inter" ta="center">
              Gathering complete vehicle specifications
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
          <Alert icon={<FiInfo size={16} />} color="red" title="Error Loading Vehicle" mb="lg">
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
    <ScrollArea h="100vh" type="auto" scrollbarSize={8}>
      <Container size="lg" py="xl">
        <Transition mounted={!loading} transition="fade" duration={300}>
          {styles => (
            <div style={styles}>
              {/* Header with navigation */}
              <Group justify="space-between" mb="xl" wrap="wrap" gap="sm">
                <Button
                  leftSection={<MdArrowBack size={18} />}
                  variant="filled"
                  color="blue.4"
                  size="md"
                  onClick={handleBackClick}
                  ff="Inter"
                  fw={500}
                  style={{
                    minWidth: '120px',
                    minHeight: '44px', // Minimum touch target
                  }}
                >
                  New VIN
                </Button>

                <Button
                  leftSection={<MdLogout size={18} />}
                  variant="filled"
                  color="dark.5"
                  size="md"
                  onClick={handleLogout}
                  ff="Inter"
                  fw={500}
                  style={{
                    minWidth: '100px',
                    minHeight: '44px', // Minimum touch target
                  }}
                >
                  Logout
                </Button>
              </Group>

              <Stack gap="xl">
                {vehicleData && (
                  <>
                    {/* Vehicle Identity Card */}
                    <Paper
                      shadow="sm"
                      p={{ base: "lg", sm: "xl" }}
                      radius="lg"
                      withBorder
                      bg="white"
                      style={{ borderColor: '#e4e4e7' }}
                    >
                      {/* Header with checkmark */}
                      <Group gap="sm" mb="lg">
                        <Text size="lg" c="green.6">✔</Text>
                        <Title order={4} ff="Inter" fw={600} c="dark.9">
                          Vehicle Identity
                        </Title>
                      </Group>

                      {/* Vehicle Details List */}
                      <Stack gap="md">
                        {/* Make */}
                        <div>
                          <Text size="xs" c="dimmed" ff="Inter" fw={500} mb={4}>Make</Text>
                          <Text size="sm" c="dark.9" ff="Inter" fw={600}>{vehicleData.make}</Text>
                        </div>

                        {/* Model */}
                        <div>
                          <Text size="xs" c="dimmed" ff="Inter" fw={500} mb={4}>Model</Text>
                          <Text size="sm" c="dark.9" ff="Inter" fw={600}>{vehicleData.model || '—'}</Text>
                        </div>

                        {/* Year */}
                        <div>
                          <Text size="xs" c="dimmed" ff="Inter" fw={500} mb={4}>Year</Text>
                          <Text size="sm" c="dark.9" ff="Inter" fw={600}>{vehicleData.year}</Text>
                        </div>

                        {/* Engine */}
                        <div>
                          <Text size="xs" c="dimmed" ff="Inter" fw={500} mb={4}>Engine</Text>
                          <Text size="sm" c="dark.9" ff="Inter" fw={600}>{vehicleData.engine || '—'}</Text>
                        </div>

                        {/* Country of Manufacture */}
                        <div>
                          <Text size="xs" c="dimmed" ff="Inter" fw={500} mb={4}>Country of Manufacture</Text>
                          <Text size="sm" c="dark.9" ff="Inter" fw={600}>{vehicleData.origin || '—'}</Text>
                        </div>
                      </Stack>

                      {/* VIN Section */}
                      <Box
                        mt="xl"
                        pt="lg"
                        style={{
                          borderTop: '1px solid #e4e4e7',
                        }}
                      >
                        <Text
                          size="xs"
                          c="dimmed"
                          ff="Inter"
                          fw={600}
                          tt="uppercase"
                          lts={0.5}
                          mb={6}
                        >
                          Vehicle Identification Number
                        </Text>
                        <Text ff="JetBrains Mono" fw={500} c="blue.5" size="lg" lts={1}>
                          {vin}
                        </Text>
                      </Box>
                    </Paper>

                    {/* 360° Vehicle Viewer - Now using web search images */}
                    {/* Always use the URL VIN parameter, not vehicleData.vin which may be modified by NHTSA */}
                    <Vehicle360Viewer
                      vin={vin}
                      vehicleName={`${vehicleData.year} ${vehicleData.make} ${vehicleData.model}`}
                      height={500}
                      dragSensitivity="medium"
                    />

                    {/* Scan Parts CTA */}
                    <Paper
                      shadow="sm"
                      p="lg"
                      radius="lg"
                      withBorder
                      bg="white"
                      style={{ borderColor: '#e4e4e7' }}
                    >
                      <Group justify="center">
                        <Button
                          leftSection={<FiCamera size={20} />}
                          variant="filled"
                          color="blue.4"
                          size="lg"
                          onClick={() => {
                            // Save current vehicle data for context in part scanner
                            // Ensure we use the original VIN from URL, not the potentially modified one
                            if (vehicleData && vin) {
                              localStorage.setItem('currentVehicle', JSON.stringify({ ...vehicleData, vin }));
                            }
                            navigate('/scan');
                          }}
                          ff="Inter"
                          fw={600}
                          style={{
                            minWidth: '200px',
                            minHeight: '48px', // Larger touch target
                          }}
                        >
                          Scan Parts with AI
                        </Button>
                      </Group>
                    </Paper>

                    {/* Vehicle Summary Card */}
                    {vehicleSummary && (
                      <Paper
                        shadow="sm"
                        p="xl"
                        radius="lg"
                        withBorder
                        bg="white"
                        style={{ borderColor: '#e4e4e7' }}
                      >
                        <Group mb="lg" align="center" gap="md">
                          <Box
                            p="sm"
                            style={{
                              backgroundColor: '#f4f4f5',
                              borderRadius: '10px',
                            }}
                          >
                            <FiInfo size={20} color="#52525b" />
                          </Box>
                          <Title order={2} ff="Inter" fw={600} c="dark.9" size="lg">
                            Technical Overview
                          </Title>
                        </Group>

                        <Stack gap="md">
                          {vehicleSummary.bulletPoints.map((point, index) => {
                            // Parse markdown-style bold text (**text**)
                            const parts = point.split(/(\*\*[^*]+\*\*)/g);
                            return (
                              <Box
                                key={index}
                                p="md"
                                style={{
                                  backgroundColor: '#fafafa',
                                  borderRadius: '8px',
                                  borderLeft: '3px solid #0ea5e9',
                                }}
                              >
                                <Text size="sm" c="dark.7" ff="Inter" fw={400} lh={1.7}>
                                  {parts.map((part, i) => {
                                    // Check if this part is bold (wrapped in **)
                                    if (part.startsWith('**') && part.endsWith('**')) {
                                      const boldText = part.slice(2, -2);
                                      return (
                                        <Text key={i} span fw={600} c="dark.9">
                                          {boldText}
                                        </Text>
                                      );
                                    }
                                    return <span key={i}>{part}</span>;
                                  })}
                                </Text>
                              </Box>
                            );
                          })}
                        </Stack>
                      </Paper>
                    )}

                    {/* Vehicle Systems & Parts Grid */}
                    <PartsGrid
                      vehicleMake={vehicleData.make}
                      vehicleModel={vehicleData.model}
                      vehicleYear={vehicleData.year}
                    />
                  </>
                )}
              </Stack>
            </div>
          )}
        </Transition>
      </Container>
    </ScrollArea>
  );
}
