import { Alert, Box, Text } from '@mantine/core';
import { MdWarning } from 'react-icons/md';

interface VinWarningProps {
    make?: string;
    model?: string;
    year?: number;
    vinValid?: boolean;
}

/**
 * Shows warning when VIN has validation issues but vehicle data was still found
 */
export function VinWarning({ make, model, year, vinValid }: VinWarningProps) {
    // Only show warning if we have some data but VIN is invalid
    if (vinValid !== false || !make) return null;

    const hasModel = model && model !== 'null';

    return (
        <Alert
            variant="light"
            color="yellow"
            title="VIN Validation Notice"
            icon={<MdWarning size={16} />}
            styles={{
                root: {
                    backgroundColor: '#fef3c7', // amber-100
                    borderColor: '#f59e0b', // amber-500
                },
                title: {
                    color: '#92400e', // amber-800
                    fontWeight: 600,
                },
                body: {
                    color: '#78350f', // amber-900
                }
            }}
        >
            <Box>
                <Text size="sm" mb={4}>
                    This VIN has structural validation issues but we found some vehicle information:
                </Text>

                <Text size="sm" fw={500} mb={8}>
                    {year} {make} {hasModel ? model : '(Model Unknown)'}
                </Text>

                <Text size="xs" c="dimmed">
                    VIN may contain errors in format or check digits. Information shown may be incomplete or estimated.
                </Text>
            </Box>
        </Alert>
    );
}