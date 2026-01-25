import { useState } from 'react';
import {
    Paper,
    Stack,
    Title,
    Text,
    TextInput,
    PasswordInput,
    Button,
    Group,
    Badge,
    Alert,
} from '@mantine/core';
import { FiLogIn, FiLogOut, FiUser } from 'react-icons/fi';
import { useAuth } from '../../contexts/AuthContext';

/**
 * AuthTest Component
 * Demonstrates the authentication system functionality
 * Shows login/logout with dummy credentials (admin/admin)
 */
export function AuthTest() {
    const { isAuthenticated, login, logout, username } = useAuth();
    const [formUsername, setFormUsername] = useState('');
    const [formPassword, setFormPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setError('');
        setLoading(true);

        try {
            const success = await login(formUsername, formPassword);

            if (success) {
                setFormUsername('');
                setFormPassword('');
            } else {
                setError('Invalid credentials. Use admin/admin');
            }
        } catch (err) {
            setError('Login failed. Please try again.');
        } finally {
            setLoading(false);
        }
    };

    const handleLogout = () => {
        logout();
        setFormUsername('');
        setFormPassword('');
        setError('');
    };

    return (
        <Paper shadow="md" p="lg" radius="md" withBorder maw={500} mx="auto">
            <Stack gap="md">
                <div>
                    <Title order={2} c="dark.9" fw={600} ff="Inter">
                        Authentication Test
                    </Title>
                    <Text c="dark.6" size="sm" ff="Inter" mt="xs">
                        Testing MotoLens dummy authentication system
                    </Text>
                </div>

                {/* Auth Status */}
                <Paper bg={isAuthenticated ? 'green.0' : 'zinc.1'} p="md" radius="md">
                    <Group justify="space-between">
                        <div>
                            <Text size="sm" c="dark.6" ff="Inter">Status</Text>
                            <Group gap="xs" mt="xs">
                                <Badge
                                    color={isAuthenticated ? 'green' : 'red'}
                                    variant="filled"
                                    leftSection={<FiUser size={14} />}
                                >
                                    {isAuthenticated ? 'Authenticated' : 'Not Authenticated'}
                                </Badge>
                                {username && (
                                    <Text size="sm" c="dark.9" ff="Inter" fw={500}>
                                        ({username})
                                    </Text>
                                )}
                            </Group>
                        </div>
                    </Group>
                </Paper>

                {/* Login Form or Logout Button */}
                {!isAuthenticated ? (
                    <>
                        <Alert color="blue.4" title="Test Credentials" variant="light">
                            <Text size="sm" ff="Inter">
                                Username: <Text component="span" ff="JetBrains Mono" fw={500}>admin</Text>
                            </Text>
                            <Text size="sm" ff="Inter">
                                Password: <Text component="span" ff="JetBrains Mono" fw={500}>admin</Text>
                            </Text>
                        </Alert>

                        <form onSubmit={handleLogin}>
                            <Stack gap="md">
                                <TextInput
                                    label="Username"
                                    placeholder="Enter username"
                                    value={formUsername}
                                    onChange={(e) => setFormUsername(e.target.value)}
                                    required
                                    size="lg"
                                    ff="Inter"
                                    error={error ? true : false}
                                />

                                <PasswordInput
                                    label="Password"
                                    placeholder="Enter password"
                                    value={formPassword}
                                    onChange={(e) => setFormPassword(e.target.value)}
                                    required
                                    size="lg"
                                    ff="Inter"
                                    error={error ? error : false}
                                />

                                <Button
                                    type="submit"
                                    color="blue.4"
                                    variant="filled"
                                    size="lg"
                                    loading={loading}
                                    leftSection={<FiLogIn size={18} />}
                                    fullWidth
                                >
                                    Login
                                </Button>
                            </Stack>
                        </form>
                    </>
                ) : (
                    <Stack gap="md">
                        <Alert color="green" title="Login Successful" variant="light">
                            <Text size="sm" ff="Inter">
                                You are now authenticated as <Text component="span" fw={600}>{username}</Text>
                            </Text>
                            <Text size="sm" ff="Inter" mt="xs">
                                Auth state is persisted in localStorage and will survive page reloads.
                            </Text>
                        </Alert>

                        <Button
                            color="red"
                            variant="filled"
                            size="lg"
                            onClick={handleLogout}
                            leftSection={<FiLogOut size={18} />}
                            fullWidth
                        >
                            Logout
                        </Button>
                    </Stack>
                )}

                {/* Technical Details */}
                <Paper bg="dark.9" p="md" radius="md">
                    <Text c="white" size="xs" ff="Inter" fw={600} mb="xs">
                        Technical Details
                    </Text>
                    <Stack gap="xs">
                        <Group gap="xs">
                            <Text c="zinc.4" size="xs" ff="Inter">localStorage Key:</Text>
                            <Text c="zinc.2" size="xs" ff="JetBrains Mono">motolens_auth</Text>
                        </Group>
                        <Group gap="xs">
                            <Text c="zinc.4" size="xs" ff="Inter">Auth State:</Text>
                            <Text c="zinc.2" size="xs" ff="JetBrains Mono">
                                {isAuthenticated ? 'true' : 'false'}
                            </Text>
                        </Group>
                        <Group gap="xs">
                            <Text c="zinc.4" size="xs" ff="Inter">Username:</Text>
                            <Text c="zinc.2" size="xs" ff="JetBrains Mono">
                                {username || 'null'}
                            </Text>
                        </Group>
                    </Stack>
                </Paper>
            </Stack>
        </Paper>
    );
}
