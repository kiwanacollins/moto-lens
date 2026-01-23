import { Container, Paper, Title, Text } from '@mantine/core';

export default function LoginPage() {
  return (
    <Container size="xs" py="xl">
      <Paper shadow="md" p="lg" radius="md" withBorder>
        <Title order={1} ta="center" mb="md">
          MOTO LENS
        </Title>
        <Text size="sm" c="dimmed" ta="center">
          Login page - Coming soon
        </Text>
      </Paper>
    </Container>
  );
}
