import { Container, Paper, Title, Text } from '@mantine/core';

export default function VehicleViewPage() {
  return (
    <Container size="lg" py="xl">
      <Paper shadow="md" p="lg" radius="md" withBorder>
        <Title order={1} ta="center" mb="md">
          Vehicle View
        </Title>
        <Text size="sm" c="dimmed" ta="center">
          Vehicle view page - Coming soon
        </Text>
      </Paper>
    </Container>
  );
}
