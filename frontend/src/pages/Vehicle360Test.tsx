import { Container, Title, Stack, Paper } from '@mantine/core';
import Vehicle360Viewer from '../components/vehicle/Vehicle360Viewer';
import type { VehicleImage } from '../types/vehicle';

// Test component to verify 360° viewer functionality
export default function Vehicle360Test() {
  // Sample car images for testing (converted to VehicleImage format)
  const sampleImages: VehicleImage[] = [
    {
      angle: 'front',
      imageUrl:
        'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400&h=300&fit=crop&auto=format',
      success: true,
      model: 'test',
      isBase64: false,
    },
    {
      angle: 'front-right',
      imageUrl:
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400&h=300&fit=crop&auto=format',
      success: true,
      model: 'test',
      isBase64: false,
    },
    {
      angle: 'right',
      imageUrl:
        'https://images.unsplash.com/photo-1494976556598-c478e0a04e7c?w=400&h=300&fit=crop&auto=format',
      success: true,
      model: 'test',
      isBase64: false,
    },
    {
      angle: 'rear-right',
      imageUrl:
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop&auto=format',
      success: true,
      model: 'test',
      isBase64: false,
    },
    {
      angle: 'rear',
      imageUrl:
        'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=400&h=300&fit=crop&auto=format',
      success: true,
      model: 'test',
      isBase64: false,
    },
    {
      angle: 'rear-left',
      imageUrl:
        'https://images.unsplash.com/photo-1544829099-b9a0c5303bea?w=400&h=300&fit=crop&auto=format',
      success: true,
      model: 'test',
      isBase64: false,
    },
    {
      angle: 'left',
      imageUrl:
        'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=400&h=300&fit=crop&auto=format',
      success: true,
      model: 'test',
      isBase64: false,
    },
    {
      angle: 'front-left',
      imageUrl:
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400&h=300&fit=crop&auto=format',
      success: true,
      model: 'test',
      isBase64: false,
    },
  ];

  return (
    <Container size="lg" py="xl">
      <Stack gap="xl">
        <Paper p="lg" radius="md" withBorder>
          <Title order={1} ff="Inter" fw={600} c="dark.9" mb="md">
            360° Vehicle Viewer Test
          </Title>

          <Vehicle360Viewer
            images={sampleImages}
            vehicleName="2020 BMW 3 Series"
            height={400}
            dragSensitivity="medium"
          />
        </Paper>

        <Paper p="lg" radius="md" withBorder>
          <Title order={2} ff="Inter" fw={600} c="dark.9" mb="md">
            High Sensitivity Test
          </Title>

          <Vehicle360Viewer
            images={sampleImages}
            vehicleName="High Sensitivity Mode"
            height={400}
            dragSensitivity="high"
          />
        </Paper>

        <Paper p="lg" radius="md" withBorder>
          <Title order={2} ff="Inter" fw={600} c="dark.9" mb="md">
            Low Sensitivity Test
          </Title>

          <Vehicle360Viewer
            images={sampleImages}
            vehicleName="Low Sensitivity Mode"
            height={400}
            dragSensitivity="low"
          />
        </Paper>

        <Paper p="lg" radius="md" withBorder>
          <Title order={2} ff="Inter" fw={600} c="dark.9" mb="md">
            Autoplay Test
          </Title>

          <Vehicle360Viewer
            images={sampleImages}
            vehicleName="Auto-rotating Vehicle"
            height={400}
            enableAutoplay={true}
            autoplaySpeed={1500}
          />
        </Paper>

        <Paper p="lg" radius="md" withBorder>
          <Title order={2} ff="Inter" fw={600} c="dark.9" mb="md">
            Loading State Test
          </Title>

          <Vehicle360Viewer
            images={[]}
            loading={true}
            vehicleName="Generating Images..."
            height={400}
          />
        </Paper>
      </Stack>
    </Container>
  );
}
