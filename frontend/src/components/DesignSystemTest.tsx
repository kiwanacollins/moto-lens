import {
  Container,
  Title,
  Text,
  Paper,
  Card,
  Badge,
  Button,
  Group,
  Stack,
  Code,
  ThemeIcon,
  SimpleGrid,
} from '@mantine/core';
import { MdDirectionsCar, MdBuild } from 'react-icons/md';
import { FiTool, FiSearch } from 'react-icons/fi';
import { BRAND_COLORS } from '../styles/theme';

/**
 * Design System Test Component
 * Showcases German Car Medic brand colors, typography, and components
 */
export function DesignSystemTest() {
  return (
    <Container size="lg" py="xl">
      <Stack gap="xl">
        {/* Header */}
        <div>
          <Title order={1} c="dark.9" fw={600} ff="Inter">
            German Car Medic Design System
          </Title>
          <Text c="dark.6" size="lg" ff="Inter" mt="xs">
            Professional Mobile-First PWA for German Vehicle Parts
          </Text>
        </div>

        {/* Brand Colors */}
        <Paper shadow="sm" p="lg" radius="md" withBorder>
          <Title order={2} c="dark.9" fw={600} ff="Inter" mb="md">
            Brand Colors
          </Title>
          <SimpleGrid cols={{ base: 1, sm: 3 }} spacing="md">
            <Paper bg="blue.4" p="lg" radius="md" style={{ border: '2px solid #e4e4e7' }}>
              <Text c="white" fw={600} ff="Inter">
                Electric Blue
              </Text>
              <Code ff="JetBrains Mono" c="white" bg="rgba(0,0,0,0.2)">
                {BRAND_COLORS.electricBlue}
              </Code>
            </Paper>

            <Paper bg="dark.9" p="lg" radius="md" style={{ border: '2px solid #e4e4e7' }}>
              <Text c="white" fw={600} ff="Inter">
                Carbon Black
              </Text>
              <Code ff="JetBrains Mono" c="white" bg="rgba(255,255,255,0.1)">
                {BRAND_COLORS.carbonBlack}
              </Code>
            </Paper>

            <Paper bg="dark.6" p="lg" radius="md" style={{ border: '2px solid #e4e4e7' }}>
              <Text c="white" fw={600} ff="Inter">
                Gunmetal Gray
              </Text>
              <Code ff="JetBrains Mono" c="white" bg="rgba(0,0,0,0.2)">
                {BRAND_COLORS.gunmetalGray}
              </Code>
            </Paper>
          </SimpleGrid>
        </Paper>

        {/* Typography */}
        <Paper shadow="sm" p="lg" radius="md" withBorder>
          <Title order={2} c="dark.9" fw={600} ff="Inter" mb="md">
            Typography
          </Title>
          <Stack gap="sm">
            <div>
              <Text c="dark.6" size="sm" ff="Inter" mb="xs">
                Inter - UI Text
              </Text>
              <Title order={3} c="dark.9" fw={600} ff="Inter">
                The quick brown fox jumps over the lazy dog
              </Title>
            </div>
            <div>
              <Text c="dark.6" size="sm" ff="Inter" mb="xs">
                JetBrains Mono - Technical Data
              </Text>
              <Code ff="JetBrains Mono" fw={500} fz="lg">
                WBADT63452CZ12345
              </Code>
            </div>
          </Stack>
        </Paper>

        {/* Icons */}
        <Paper shadow="sm" p="lg" radius="md" withBorder>
          <Title order={2} c="dark.9" fw={600} ff="Inter" mb="md">
            Icons (react-icons)
          </Title>
          <Group gap="md">
            <ThemeIcon color="blue.4" size="xl" radius="md">
              <MdDirectionsCar size={28} />
            </ThemeIcon>
            <ThemeIcon color="dark.9" size="xl" radius="md" variant="light">
              <FiTool size={24} />
            </ThemeIcon>
            <ThemeIcon color="dark.6" size="xl" radius="md" variant="outline">
              <MdBuild size={24} />
            </ThemeIcon>
            <ThemeIcon color="green" size="xl" radius="md">
              <FiSearch size={24} />
            </ThemeIcon>
          </Group>
        </Paper>

        {/* Badges */}
        <Paper shadow="sm" p="lg" radius="md" withBorder>
          <Title order={2} c="dark.9" fw={600} ff="Inter" mb="md">
            Badges
          </Title>
          <Group gap="md">
            <Badge color="blue.4" variant="filled">
              In Stock
            </Badge>
            <Badge color="green" variant="filled">
              Available
            </Badge>
            <Badge color="red" variant="filled">
              Out of Stock
            </Badge>
            <Badge color="yellow" variant="filled">
              Low Stock
            </Badge>
            <Badge color="blue.4" variant="outline">
              OEM Part
            </Badge>
            <Badge color="dark.6" variant="light">
              Compatible
            </Badge>
          </Group>
        </Paper>

        {/* Buttons */}
        <Paper shadow="sm" p="lg" radius="md" withBorder>
          <Title order={2} c="dark.9" fw={600} ff="Inter" mb="md">
            Buttons
          </Title>
          <Group gap="md">
            <Button color="blue.4" variant="filled" size="lg">
              Primary Action
            </Button>
            <Button variant="outline" color="dark.6" size="lg">
              Secondary
            </Button>
            <Button color="red" variant="filled" size="lg">
              Destructive
            </Button>
          </Group>
        </Paper>

        {/* Card Example */}
        <Card shadow="md" padding="lg" radius="md" withBorder>
          <Group justify="space-between" mb="md">
            <Group gap="sm">
              <MdDirectionsCar size={24} style={{ color: BRAND_COLORS.electricBlue }} />
              <Title order={3} c="dark.9" fw={600} ff="Inter">
                2020 BMW 3 Series
              </Title>
            </Group>
            <Badge color="blue.4" variant="filled">
              Active
            </Badge>
          </Group>

          <Stack gap="sm">
            <Group gap="xs">
              <Text c="dark.6" size="sm" ff="Inter">
                VIN:
              </Text>
              <Code ff="JetBrains Mono" c="dark.9" fw={500}>
                WBADT63452CZ12345
              </Code>
            </Group>
            <Text c="dark.6" size="sm" ff="Inter">
              2.0L Turbo • Sedan • 4 Doors
            </Text>
          </Stack>

          <Group gap="md" mt="lg">
            <Button color="blue.4" variant="filled" size="lg" leftSection={<FiTool size={18} />}>
              View Parts
            </Button>
            <Button variant="outline" color="dark.6" size="lg">
              Details
            </Button>
          </Group>
        </Card>

        {/* Semantic Colors */}
        <Paper shadow="sm" p="lg" radius="md" withBorder>
          <Title order={2} c="dark.9" fw={600} ff="Inter" mb="md">
            Semantic Colors
          </Title>
          <Stack gap="sm">
            <Paper bg="green.4" p="md" radius="md">
              <Text c="white" fw={500} ff="Inter">
                ✓ Success: VIN decoded successfully
              </Text>
            </Paper>
            <Paper bg="yellow.4" p="md" radius="md">
              <Text c="dark.9" fw={500} ff="Inter">
                ⚠ Warning: Part availability limited
              </Text>
            </Paper>
            <Paper bg="red.4" p="md" radius="md">
              <Text c="white" fw={500} ff="Inter">
                ✕ Error: Invalid VIN format
              </Text>
            </Paper>
            <Paper bg="blue.4" p="md" radius="md">
              <Text c="white" fw={500} ff="Inter">
                ℹ Info: 8 parts available for this vehicle
              </Text>
            </Paper>
          </Stack>
        </Paper>

        {/* Dark Card Example */}
        <Paper bg="dark.9" p="lg" radius="md">
          <Title order={2} c="white" fw={600} ff="Inter" mb="md">
            Dark Mode Card
          </Title>
          <Text c="zinc.3" size="sm" ff="Inter" mb="lg">
            Professional dark backgrounds with high contrast text
          </Text>
          <Group gap="md">
            <Button color="blue.4" variant="filled" size="lg">
              Electric Blue CTA
            </Button>
            <Button variant="outline" color="zinc.3" size="lg">
              Subtle Secondary
            </Button>
          </Group>
        </Paper>

        {/* Footer */}
        <Paper
          shadow="xs"
          p="md"
          radius="md"
          withBorder
          style={{ borderTop: '3px solid ' + BRAND_COLORS.electricBlue }}
        >
          <Text c="dark.6" size="sm" ff="Inter" ta="center">
            ✅ Design System: Professional, Mobile-First, No AI Slop
          </Text>
        </Paper>
      </Stack>
    </Container>
  );
}
