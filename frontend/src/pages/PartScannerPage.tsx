/**
 * Part Scanner Page
 *
 * Main page for scanning and analyzing spare parts using computer vision
 * Integrates camera, analysis, and question features
 */

import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Container,
  Stack,
  Text,
  Paper,
  Group,
  Button,
  Grid,
  ActionIcon,
  Alert,
  Tabs,
  ThemeIcon,
} from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { MdArrowBack, MdCameraAlt, MdQrCode, MdHealthAndSafety, MdInfo } from 'react-icons/md';
import { FiTool, FiCamera } from 'react-icons/fi';
import { useAuth } from '../contexts/AuthContext';
import PartCamera from '../components/parts/PartCamera';
import PartAnalysis from '../components/parts/PartAnalysis';
import type { PartScanResult, VehicleContext } from '../services/partScanService';
import {
  scanPartImage,
  detectPartMarkings,
  assessPartCondition,
} from '../services/partScanService';

type ScanMode = 'analyze' | 'compare' | 'markings' | 'condition';

export const PartScannerPage = () => {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();

  const [activeTab, setActiveTab] = useState<ScanMode>('analyze');
  const [currentImage, setCurrentImage] = useState<File | null>(null);
  const [analysisResult, setAnalysisResult] = useState<PartScanResult | null>(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [vehicleContext, setVehicleContext] = useState<VehicleContext | null>(null);

  // Redirect if not authenticated
  useEffect(() => {
    if (!isAuthenticated) {
      navigate('/login');
    }
  }, [isAuthenticated, navigate]);

  // Load vehicle context from localStorage (if coming from vehicle view)
  useEffect(() => {
    const savedVehicle = localStorage.getItem('currentVehicle');
    if (savedVehicle) {
      try {
        const vehicle = JSON.parse(savedVehicle);
        setVehicleContext({
          make: vehicle.make,
          model: vehicle.model,
          year: vehicle.year,
          engine: vehicle.engine,
        });
      } catch (err) {
        console.warn('Failed to parse saved vehicle:', err);
      }
    }
  }, []);

  // Handle image capture/upload
  const handleImageCapture = async (file: File) => {
    setCurrentImage(file);
    setError(null);
    setAnalysisResult(null);
    setIsAnalyzing(true);

    try {
      let result: PartScanResult;

      switch (activeTab) {
        case 'analyze':
          result = await scanPartImage(file, vehicleContext || undefined);
          break;
        case 'markings':
          result = (await detectPartMarkings(file)) as PartScanResult;
          break;
        case 'condition':
          result = await assessPartCondition(file, vehicleContext || undefined);
          break;
        default:
          result = await scanPartImage(file, vehicleContext || undefined);
      }

      setAnalysisResult(result);

      notifications.show({
        title: 'Analysis complete',
        message: 'Part information has been analyzed successfully',
        color: 'green',
        icon: <MdCameraAlt />,
      });
    } catch (err) {
      console.error('Analysis error:', err);
      const errorMessage = err instanceof Error ? err.message : 'Failed to analyze part';
      setError(errorMessage);

      notifications.show({
        title: 'Analysis failed',
        message: errorMessage,
        color: 'red',
      });
    } finally {
      setIsAnalyzing(false);
    }
  };

  // Retry analysis
  const handleRetry = () => {
    if (currentImage) {
      handleImageCapture(currentImage);
    }
  };

  // Clear current analysis
  const handleClear = () => {
    setCurrentImage(null);
    setAnalysisResult(null);
    setError(null);
  };

  if (!isAuthenticated) {
    return null; // Will redirect
  }

  return (
    <Container size="lg" py="xl">
      <Stack gap="xl">
        {/* Header */}
        <Group justify="space-between" wrap="wrap" gap="sm">
          <Group gap="md">
            <ActionIcon
              variant="subtle"
              color="dark.6"
              size="xl"
              onClick={() => navigate(-1)}
              style={{
                minWidth: '44px',
                minHeight: '44px', // Minimum touch target
              }}
            >
              <MdArrowBack size={20} />
            </ActionIcon>
            <Stack gap={4}>
              <Text size="xl" fw={700} c="dark.9" ff="Inter">
                Part Scanner
              </Text>
              <Text size="sm" c="dark.6" ff="Inter" visibleFrom="xs">
                Use AI to analyze spare parts from photos
              </Text>
            </Stack>
          </Group>
        </Group>

        {/* Vehicle Context */}
        {vehicleContext && (
          <Alert icon={<MdInfo />} color="blue" variant="light">
            <Text size="sm" ff="Inter">
              <strong>Vehicle Context:</strong> {vehicleContext.year} {vehicleContext.make}{' '}
              {vehicleContext.model}
              {vehicleContext.engine && ` • ${vehicleContext.engine}`}
            </Text>
          </Alert>
        )}

        {/* Scan Mode Tabs */}
        <Tabs value={activeTab} onChange={value => setActiveTab(value as ScanMode)}>
          <Tabs.List grow>
            <Tabs.Tab value="analyze" leftSection={<FiTool size={16} />} ff="Inter" fw={500}>
              <Text visibleFrom="xs">Analyze Part</Text>
              <Text hiddenFrom="xs">Analyze</Text>
            </Tabs.Tab>
            <Tabs.Tab value="markings" leftSection={<MdQrCode size={16} />} ff="Inter" fw={500}>
              <Text visibleFrom="xs">Read Markings</Text>
              <Text hiddenFrom="xs">Markings</Text>
            </Tabs.Tab>
            <Tabs.Tab
              value="condition"
              leftSection={<MdHealthAndSafety size={16} />}
              ff="Inter"
              fw={500}
            >
              Check Condition
            </Tabs.Tab>
          </Tabs.List>

          {/* Analyze Tab */}
          <Tabs.Panel value="analyze" pt="md">
            <Stack gap="lg">
              <Paper p="md" withBorder bg="gray.0">
                <Group gap="sm">
                  <ThemeIcon size="sm" color="blue.4" variant="light">
                    <FiTool size={14} />
                  </ThemeIcon>
                  <Text size="sm" c="dark.7" ff="Inter">
                    <strong>Part Analysis:</strong> Identify the part, get technical specs,
                    compatibility info, and replacement recommendations.
                  </Text>
                </Group>
              </Paper>

              <Grid>
                <Grid.Col span={{ base: 12, md: 6 }}>
                  {/* Camera Section */}
                  <Paper shadow="sm" p="lg" radius="md" withBorder h="100%">
                    <Stack gap="md" align="center" h="100%" justify="center">
                      <ThemeIcon size="xl" color="blue.4" variant="light">
                        <FiCamera size={24} />
                      </ThemeIcon>
                      <Stack gap="xs" align="center">
                        <Text fw={600} c="dark.9" ff="Inter">
                          Scan Spare Part
                        </Text>
                        <Text size="sm" c="dark.6" ta="center" ff="Inter">
                          Take a photo or upload an image of the part you want to analyze
                        </Text>
                      </Stack>
                      <PartCamera onImageCapture={handleImageCapture} isProcessing={isAnalyzing} />
                    </Stack>
                  </Paper>
                </Grid.Col>

                <Grid.Col span={{ base: 12, md: 6 }}>
                  {/* Results Section */}
                  <PartAnalysis
                    result={analysisResult}
                    imageFile={currentImage}
                    vehicleContext={vehicleContext || undefined}
                    isLoading={isAnalyzing}
                    error={error}
                    onRetry={handleRetry}
                  />
                </Grid.Col>
              </Grid>
            </Stack>
          </Tabs.Panel>

          {/* Markings Tab */}
          <Tabs.Panel value="markings" pt="md">
            <Stack gap="lg">
              <Paper p="md" withBorder bg="gray.0">
                <Group gap="sm">
                  <ThemeIcon size="sm" color="blue.4" variant="light">
                    <MdQrCode size={14} />
                  </ThemeIcon>
                  <Text size="sm" c="dark.7" ff="Inter">
                    <strong>Marking Detection:</strong> Extract part numbers, brand markings, and
                    technical specifications from the part image.
                  </Text>
                </Group>
              </Paper>

              <Grid>
                <Grid.Col span={{ base: 12, md: 6 }}>
                  <Paper shadow="sm" p="lg" radius="md" withBorder h="100%">
                    <Stack gap="md" align="center" h="100%" justify="center">
                      <ThemeIcon size="xl" color="blue.4" variant="light">
                        <MdQrCode size={24} />
                      </ThemeIcon>
                      <Stack gap="xs" align="center">
                        <Text fw={600} c="dark.9" ff="Inter">
                          Read Part Markings
                        </Text>
                        <Text size="sm" c="dark.6" ta="center" ff="Inter">
                          Capture clear images of part numbers and text markings
                        </Text>
                      </Stack>
                      <PartCamera onImageCapture={handleImageCapture} isProcessing={isAnalyzing} />
                    </Stack>
                  </Paper>
                </Grid.Col>

                <Grid.Col span={{ base: 12, md: 6 }}>
                  <PartAnalysis
                    result={analysisResult}
                    imageFile={currentImage}
                    vehicleContext={vehicleContext || undefined}
                    isLoading={isAnalyzing}
                    error={error}
                    onRetry={handleRetry}
                  />
                </Grid.Col>
              </Grid>
            </Stack>
          </Tabs.Panel>

          {/* Condition Tab */}
          <Tabs.Panel value="condition" pt="md">
            <Stack gap="lg">
              <Paper p="md" withBorder bg="gray.0">
                <Group gap="sm">
                  <ThemeIcon size="sm" color="blue.4" variant="light">
                    <MdHealthAndSafety size={14} />
                  </ThemeIcon>
                  <Text size="sm" c="dark.7" ff="Inter">
                    <strong>Condition Assessment:</strong> Analyze part wear, damage, and get
                    replacement recommendations based on current state.
                  </Text>
                </Group>
              </Paper>

              <Grid>
                <Grid.Col span={{ base: 12, md: 6 }}>
                  <Paper shadow="sm" p="lg" radius="md" withBorder h="100%">
                    <Stack gap="md" align="center" h="100%" justify="center">
                      <ThemeIcon size="xl" color="blue.4" variant="light">
                        <MdHealthAndSafety size={24} />
                      </ThemeIcon>
                      <Stack gap="xs" align="center">
                        <Text fw={600} c="dark.9" ff="Inter">
                          Assess Part Condition
                        </Text>
                        <Text size="sm" c="dark.6" ta="center" ff="Inter">
                          Show wear, damage, or problem areas clearly in the photo
                        </Text>
                      </Stack>
                      <PartCamera onImageCapture={handleImageCapture} isProcessing={isAnalyzing} />
                    </Stack>
                  </Paper>
                </Grid.Col>

                <Grid.Col span={{ base: 12, md: 6 }}>
                  <PartAnalysis
                    result={analysisResult}
                    imageFile={currentImage}
                    vehicleContext={vehicleContext || undefined}
                    isLoading={isAnalyzing}
                    error={error}
                    onRetry={handleRetry}
                  />
                </Grid.Col>
              </Grid>
            </Stack>
          </Tabs.Panel>
        </Tabs>

        {/* Quick Actions */}
        {(currentImage || analysisResult) && (
          <Group justify="center" gap="sm">
            <Button
              variant="outline"
              color="dark.6"
              onClick={handleClear}
              ff="Inter"
              size="sm"
              style={{
                minWidth: '160px',
                minHeight: '44px', // Minimum touch target
              }}
            >
              Clear & Scan New Part
            </Button>
          </Group>
        )}
      </Stack>
    </Container>
  );
};

export default PartScannerPage;
