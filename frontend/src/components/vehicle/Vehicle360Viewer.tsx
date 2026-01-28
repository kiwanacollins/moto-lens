import { useState, useEffect } from 'react';
import { Paper, Alert, Text, Center } from '@mantine/core';

// Import our custom 360 viewer (React 19 compatible)
import Custom360Viewer from './Custom360Viewer';

// Import vehicle service and types
import { getVehicleImages } from '../../services/vehicleService';
import type { VehicleImage } from '../../types/vehicle';

interface Vehicle360ViewerProps {
  images?: VehicleImage[];
  loading?: boolean;
  vehicleName?: string;
  className?: string;
  height?: number;
  // Sensitivity configuration props
  dragSensitivity?: 'low' | 'medium' | 'high';
  enableAutoplay?: boolean;
  autoplaySpeed?: number;
  // Vehicle VIN for loading images from web search
  vin?: string;
  // Legacy vehicle data (will be deprecated)
  vehicleData?: any;
  onImagesLoaded?: (images: VehicleImage[]) => void;
}

export default function Vehicle360Viewer({
  images = [],
  loading = false,
  vehicleName = '',
  className = '',
  height = 400,
  dragSensitivity = 'medium',
  enableAutoplay = false,
  autoplaySpeed = 2000,
  vin = '',
  vehicleData = null,
  onImagesLoaded = () => {},
}: Vehicle360ViewerProps) {
  const [backendImages, setBackendImages] = useState<VehicleImage[]>([]);
  const [loadingImages, setLoadingImages] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Effect to load images from backend when VIN is provided
  useEffect(() => {
    // Prioritize VIN over legacy vehicleData
    const vinToUse = vin || vehicleData?.vin;

    if (!vinToUse || backendImages.length > 0) return;

    async function loadBackendImages() {
      try {
        setLoadingImages(true);
        setError(null);

        console.log(`Loading vehicle images for VIN: ${vinToUse}`);
        const vehicleImages = await getVehicleImages(vinToUse);

        console.log(`Loaded ${vehicleImages.length} images:`, vehicleImages);
        setBackendImages(vehicleImages);
        onImagesLoaded(vehicleImages);
      } catch (error) {
        console.error('Failed to load vehicle images:', error);
        setError(error instanceof Error ? error.message : 'Failed to load vehicle images');
        setBackendImages([]);
      } finally {
        setLoadingImages(false);
      }
    }

    loadBackendImages();
  }, [vin, vehicleData?.vin, onImagesLoaded, backendImages.length]);

  // Determine which images to use
  const finalImages = backendImages.length > 0 ? backendImages : images;

  // Show error state
  if (error && !loadingImages && finalImages.length === 0) {
    return (
      <Paper
        shadow="sm"
        p="xl"
        radius="lg"
        withBorder
        h={height}
        className={className}
        style={{ borderColor: '#e4e4e7', backgroundColor: '#ffffff' }}
      >
        <Center h="100%">
          <Alert color="red" title="Image Load Error">
            <Text size="sm">{error}</Text>
            <Text size="xs" c="dimmed" mt="xs">
              Check your internet connection and try again.
            </Text>
          </Alert>
        </Center>
      </Paper>
    );
  }

  // Use our custom 360 viewer
  return (
    <Custom360Viewer
      images={finalImages}
      loading={loading || loadingImages}
      vehicleName={vehicleName}
      className={className}
      height={height}
      dragSensitivity={dragSensitivity}
      enableAutoplay={enableAutoplay}
      autoplaySpeed={autoplaySpeed}
    />
  );
}
