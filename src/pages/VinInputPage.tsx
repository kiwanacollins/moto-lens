import { Container, Paper, Title, Text } from '@mantine/core';

export default function VinInputPage() {
  return (
    <Container size="sm" py="xl">
      <Paper shadow="md" p="lg" radius="md" withBorder>
        <Title order={1} ta="center" mb="md">
          VIN Decoder
        </Title>
        <Text size="sm" c="dimmed" ta="center">
          VIN input page - Coming soon
        </Text>
      </Paper>
    </Container>
  );
}
