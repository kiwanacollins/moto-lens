import { Paper, Stack, Text, Group, Badge, Code, Button, Divider } from '@mantine/core';
import { MdShoppingCart, MdSpeed, MdConstruction } from 'react-icons/md';
import { FiTruck } from 'react-icons/fi';
import type { Hotspot, AftermarketAlternative } from '../../types/parts';

interface SparePartsListProps {
    hotspot: Hotspot;
    vehicleMake?: 'bmw' | 'audi' | 'mercedes' | 'vw' | 'porsche';
}

export function SparePartsList({ hotspot, vehicleMake = 'bmw' }: SparePartsListProps) {
    // Get OEM part number for the specific vehicle make
    const oemPartNumber = hotspot.oemPartNumbers?.[vehicleMake];

    // Priority ranking based on failure frequency
    const getPriorityColor = (frequency?: string) => {
        switch (frequency) {
            case 'frequent': return '#ef4444'; // Red for high priority
            case 'common': return '#f59e0b'; // Amber for medium priority
            case 'occasional': return '#10b981'; // Green for low priority
            case 'rare': return '#6b7280'; // Gray for very low priority
            default: return '#6b7280';
        }
    };

    const getPriorityLabel = (frequency?: string) => {
        switch (frequency) {
            case 'frequent': return 'High Priority';
            case 'common': return 'Medium Priority';
            case 'occasional': return 'Low Priority';
            case 'rare': return 'Very Low Priority';
            default: return 'Unknown';
        }
    };

    // Installation difficulty indicator
    const getDifficultyIcon = (partName: string) => {
        // Simple heuristic based on part type
        if (partName.toLowerCase().includes('mirror') || partName.toLowerCase().includes('light')) {
            return { icon: MdSpeed, label: 'Easy', color: '#10b981' };
        }
        if (partName.toLowerCase().includes('bumper') || partName.toLowerCase().includes('door')) {
            return { icon: MdConstruction, label: 'Moderate', color: '#f59e0b' };
        }
        return { icon: MdConstruction, label: 'Expert', color: '#ef4444' };
    };

    const difficulty = getDifficultyIcon(hotspot.partName);

    return (
        <Paper
            shadow="sm"
            p="lg"
            radius="md"
            withBorder
            style={{
                backgroundColor: '#ffffff',
                border: '1px solid #e4e4e7',
                position: 'relative',
            }}
        >
            {/* Red dot indicator - matching hotspot style */}
            <div
                style={{
                    position: 'absolute',
                    top: '16px',
                    left: '16px',
                    width: '12px',
                    height: '12px',
                    backgroundColor: '#ef4444', // Red dot matching hotspots
                    borderRadius: '50%',
                    boxShadow: '0 2px 4px rgba(239, 68, 68, 0.3)',
                }}
            />

            {/* Connecting line visual element */}
            <div
                style={{
                    position: 'absolute',
                    top: '16px',
                    left: '28px',
                    width: '24px',
                    height: '2px',
                    backgroundColor: '#ef4444',
                }}
            />

            <Stack gap="lg" style={{ marginLeft: '40px' }}>
                {/* Part Header */}
                <Group justify="space-between" align="flex-start">
                    <div style={{ flex: 1 }}>
                        <Text ff="Inter" fw={600} size="lg" c="#0a0a0a">
                            {hotspot.partName}
                        </Text>
                        <Text ff="Inter" size="sm" c="#52525b" mt="xs">
                            Location: {hotspot.angle} • ID: {hotspot.id}
                        </Text>
                    </div>

                    {/* Priority Badge */}
                    <Badge
                        color={getPriorityColor(hotspot.failureFrequency?.replacementFrequency)}
                        variant="dot"
                        size="lg"
                        ff="Inter"
                        fw={500}
                        style={{
                            backgroundColor: `${getPriorityColor(hotspot.failureFrequency?.replacementFrequency)}15`,
                            color: getPriorityColor(hotspot.failureFrequency?.replacementFrequency),
                        }}
                    >
                        {getPriorityLabel(hotspot.failureFrequency?.replacementFrequency)}
                    </Badge>
                </Group>

                {/* OEM Part Information */}
                {oemPartNumber && (
                    <Paper bg="#f4f4f5" p="md" radius="sm" style={{ border: '1px solid #e4e4e7' }}>
                        <Group justify="space-between" align="center">
                            <div>
                                <Text ff="Inter" size="sm" fw={600} c="#0a0a0a" mb="xs">
                                    OEM Part ({vehicleMake.toUpperCase()})
                                </Text>
                                <Code
                                    ff="JetBrains Mono"
                                    fw={500}
                                    c="#0a0a0a"
                                    style={{
                                        backgroundColor: '#ffffff',
                                        border: '1px solid #e4e4e7',
                                        borderRadius: '4px',
                                        padding: '4px 8px',
                                        fontSize: '14px',
                                    }}
                                >
                                    {oemPartNumber}
                                </Code>
                            </div>
                            <Badge color="blue.4" variant="filled" size="sm" ff="Inter">
                                Genuine
                            </Badge>
                        </Group>
                    </Paper>
                )}

                {/* Aftermarket Alternatives */}
                {hotspot.aftermarketAlternatives && hotspot.aftermarketAlternatives.length > 0 && (
                    <div>
                        <Group gap="xs" align="center" mb="sm">
                            {/* Red dot for section */}
                            <div
                                style={{
                                    width: '8px',
                                    height: '8px',
                                    backgroundColor: '#ef4444',
                                    borderRadius: '50%',
                                }}
                            />
                            <Text ff="Inter" fw={600} size="md" c="#0a0a0a">
                                Aftermarket Alternatives
                            </Text>
                        </Group>

                        <Stack gap="sm">
                            {hotspot.aftermarketAlternatives.map((alt: AftermarketAlternative, index: number) => (
                                <Paper
                                    key={index}
                                    bg="#ffffff"
                                    p="sm"
                                    radius="sm"
                                    style={{
                                        border: '1px solid #e4e4e7',
                                        borderLeft: '3px solid #0ea5e9', // Electric Blue accent
                                    }}
                                >
                                    <Group justify="space-between" align="center">
                                        <div style={{ flex: 1 }}>
                                            <Group gap="sm" align="center">
                                                <Text ff="Inter" fw={500} size="sm" c="#0a0a0a">
                                                    {alt.brand}
                                                </Text>
                                                <Code
                                                    ff="JetBrains Mono"
                                                    c="#52525b"
                                                    style={{
                                                        backgroundColor: 'transparent',
                                                        fontSize: '12px',
                                                    }}
                                                >
                                                    {alt.partNumber}
                                                </Code>
                                            </Group>
                                            <Text ff="Inter" size="xs" c="#52525b">
                                                Quality: {alt.qualityRating.toFixed(1)}/5.0
                                            </Text>
                                        </div>
                                        <Badge
                                            variant="light"
                                            color="green"
                                            size="sm"
                                            ff="Inter"
                                            fw={500}
                                        >
                                            {alt.priceRange}
                                        </Badge>
                                    </Group>
                                </Paper>
                            ))}
                        </Stack>
                    </div>
                )}

                {/* Failure Information */}
                {hotspot.failureFrequency && (
                    <div>
                        <Group gap="xs" align="center" mb="sm">
                            <div
                                style={{
                                    width: '8px',
                                    height: '8px',
                                    backgroundColor: '#ef4444',
                                    borderRadius: '50%',
                                }}
                            />
                            <Text ff="Inter" fw={600} size="md" c="#0a0a0a">
                                Common Issues & Lifespan
                            </Text>
                        </Group>

                        <Group gap="lg" align="flex-start">
                            <div style={{ flex: 1 }}>
                                <Text ff="Inter" size="sm" fw={500} c="#52525b" mb="xs">
                                    Common Problems:
                                </Text>
                                <Stack gap="xs">
                                    {hotspot.failureFrequency.commonIssues.map((issue, index) => (
                                        <Group key={index} gap="xs" align="flex-start">
                                            <div
                                                style={{
                                                    width: '4px',
                                                    height: '4px',
                                                    backgroundColor: '#ef4444',
                                                    borderRadius: '50%',
                                                    marginTop: '8px',
                                                    flexShrink: 0,
                                                }}
                                            />
                                            <Text ff="Inter" size="sm" c="#52525b" style={{ lineHeight: 1.4 }}>
                                                {issue}
                                            </Text>
                                        </Group>
                                    ))}
                                </Stack>
                            </div>

                            <Paper bg="#f4f4f5" p="sm" radius="sm" style={{ minWidth: '140px' }}>
                                <Text ff="Inter" size="xs" c="#52525b" ta="center" mb="xs">
                                    Expected Lifespan
                                </Text>
                                <Text ff="Inter" fw={600} size="lg" c="#0a0a0a" ta="center">
                                    {hotspot.failureFrequency.avgLifespanYears} years
                                </Text>
                            </Paper>
                        </Group>
                    </div>
                )}

                <Divider color="#e4e4e7" />

                {/* Action Buttons */}
                <Group gap="sm">
                    <Button
                        leftSection={<MdShoppingCart size={18} />}
                        color="blue.4"
                        variant="filled"
                        size="sm"
                        ff="Inter"
                        fw={500}
                        style={{
                            backgroundColor: '#0ea5e9',
                            minHeight: '44px', // Garage-friendly tap target
                        }}
                    >
                        View Suppliers
                    </Button>

                    <Button
                        leftSection={<FiTruck size={18} />}
                        variant="outline"
                        color="blue.4"
                        size="sm"
                        ff="Inter"
                        fw={500}
                        style={{
                            borderColor: '#0ea5e9',
                            color: '#0ea5e9',
                            minHeight: '44px',
                        }}
                    >
                        Check Stock
                    </Button>

                    <Button
                        leftSection={<difficulty.icon size={18} />}
                        variant="light"
                        color="gray"
                        size="sm"
                        ff="Inter"
                        fw={500}
                        style={{
                            backgroundColor: `${difficulty.color}15`,
                            color: difficulty.color,
                            minHeight: '44px',
                        }}
                    >
                        {difficulty.label} Install
                    </Button>
                </Group>
            </Stack>
        </Paper>
    );
}

export default SparePartsList;