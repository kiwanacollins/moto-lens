import { Modal, Title, Text, Group, Button, Stack, Code, Badge } from '@mantine/core';
import { MdClose } from 'react-icons/md';
import type { PartInfo, Hotspot } from '../../types/parts';

interface PartDetailModalProps {
    opened: boolean;
    onClose: () => void;
    partInfo: PartInfo | null;
    clickedHotspot: Hotspot | null;
    loading?: boolean;
}

export function PartDetailModal({
    opened,
    onClose,
    partInfo,
    clickedHotspot: _clickedHotspot,
    loading = false
}: PartDetailModalProps) {
    return (
        <Modal
            opened={opened}
            onClose={onClose}
            size="md"
            radius="md"
            centered
            withCloseButton={false}
            overlayProps={{
                backgroundOpacity: 0.75,
                blur: 3,
            }}
            styles={{
                content: {
                    backgroundColor: '#0a0a0a', // Carbon Black background
                    border: 'none',
                    position: 'relative',
                },
                body: {
                    padding: 0,
                },
            }}
        >
            {/* Electric Blue header */}
            <div
                style={{
                    backgroundColor: '#0ea5e9', // Electric Blue
                    padding: '8px 20px',
                    borderTopLeftRadius: '8px',
                    borderTopRightRadius: '8px',
                    position: 'relative',
                }}
            >
                <Group justify="space-between" align="center">
                    <Title
                        order={3}
                        c="white"
                        ff="Inter"
                        fw={600}
                        size="lg"
                        style={{ margin: 0 }}
                    >
                        {loading ? 'Loading Part Details...' : partInfo?.name || 'Part Information'}
                    </Title>

                    {/* Large close button - garage/glove friendly */}
                    <Button
                        variant="subtle"
                        size="md"
                        p={8}
                        onClick={onClose}
                        style={{
                            color: 'white',
                            backgroundColor: 'rgba(255, 255, 255, 0.1)',
                            border: 'none',
                            borderRadius: '6px',
                            minWidth: '44px',
                            minHeight: '44px',
                        }}
                        styles={{
                            root: {
                                '&:hover': {
                                    backgroundColor: 'rgba(255, 255, 255, 0.2)',
                                },
                                '&:active': {
                                    backgroundColor: 'rgba(255, 255, 255, 0.3)',
                                    transform: 'scale(0.95)',
                                },
                            },
                        }}
                    >
                        <MdClose size={24} />
                    </Button>
                </Group>
            </div>

            {/* White content area */}
            <div
                style={{
                    backgroundColor: '#ffffff',
                    padding: '24px',
                    borderBottomLeftRadius: '8px',
                    borderBottomRightRadius: '8px',
                }}
            >
                {loading ? (
                    <Stack gap="md">
                        <div
                            style={{
                                height: '20px',
                                backgroundColor: '#f4f4f5',
                                borderRadius: '4px',
                                animation: 'pulse 2s infinite',
                            }}
                        />
                        <div
                            style={{
                                height: '60px',
                                backgroundColor: '#f4f4f5',
                                borderRadius: '4px',
                                animation: 'pulse 2s infinite',
                            }}
                        />
                        <div
                            style={{
                                height: '40px',
                                backgroundColor: '#f4f4f5',
                                borderRadius: '4px',
                                animation: 'pulse 2s infinite',
                            }}
                        />
                    </Stack>
                ) : partInfo ? (
                    <Stack gap="lg">
                        {/* Part number - technical data with JetBrains Mono */}
                        {partInfo.partNumber && (
                            <Group>
                                <Text c="#52525b" ff="Inter" size="sm" fw={500}>
                                    Part Number:
                                </Text>
                                <Code
                                    ff="JetBrains Mono"
                                    fw={500}
                                    c="#0a0a0a"
                                    style={{
                                        backgroundColor: '#f4f4f5',
                                        border: '1px solid #e4e4e7',
                                        borderRadius: '4px',
                                        padding: '4px 8px',
                                    }}
                                >
                                    {partInfo.partNumber}
                                </Code>
                            </Group>
                        )}

                        {/* Function description - Inter font for readability */}
                        {partInfo.description && (
                            <div>
                                <Text c="#0a0a0a" ff="Inter" fw={600} size="sm" mb="xs">
                                    Function & Description
                                </Text>
                                <Text c="#52525b" ff="Inter" size="sm" style={{ lineHeight: 1.6 }}>
                                    {partInfo.description}
                                </Text>
                            </div>
                        )}

                        {/* Common failure symptoms - mechanic insights */}
                        {partInfo.symptoms && partInfo.symptoms.length > 0 && (
                            <div>
                                <Text c="#0a0a0a" ff="Inter" fw={600} size="sm" mb="xs">
                                    Common Symptoms When Faulty
                                </Text>
                                <Stack gap="xs">
                                    {partInfo.symptoms.map((symptom, index) => (
                                        <Group key={index} gap="xs" align="flex-start">
                                            <div
                                                style={{
                                                    width: '6px',
                                                    height: '6px',
                                                    backgroundColor: '#ef4444', // Red bullet matching theme
                                                    borderRadius: '50%',
                                                    marginTop: '6px',
                                                    flexShrink: 0,
                                                }}
                                            />
                                            <Text c="#52525b" ff="Inter" size="sm" style={{ lineHeight: 1.5 }}>
                                                {symptom}
                                            </Text>
                                        </Group>
                                    ))}
                                </Stack>
                            </div>
                        )}

                        {/* Related spare parts - max 5 as per requirements */}
                        {partInfo.spareParts && partInfo.spareParts.length > 0 && (
                            <div>
                                <Text c="#0a0a0a" ff="Inter" fw={600} size="sm" mb="xs">
                                    Related Spare Parts
                                </Text>
                                <Stack gap="sm">
                                    {partInfo.spareParts.slice(0, 5).map((sparePart, index) => (
                                        <Group key={index} justify="space-between" align="center">
                                            <div style={{ flex: 1 }}>
                                                <Text c="#0a0a0a" ff="Inter" size="sm" fw={500}>
                                                    {sparePart.name}
                                                </Text>
                                                {sparePart.partNumber && (
                                                    <Code
                                                        ff="JetBrains Mono"
                                                        c="#52525b"
                                                        style={{
                                                            backgroundColor: 'transparent',
                                                            border: 'none',
                                                            padding: 0,
                                                            fontSize: '12px',
                                                        }}
                                                    >
                                                        {sparePart.partNumber}
                                                    </Code>
                                                )}
                                            </div>
                                            {sparePart.price && (
                                                <Badge
                                                    variant="light"
                                                    color="blue.4"
                                                    size="sm"
                                                    ff="Inter"
                                                    fw={500}
                                                >
                                                    ${sparePart.price}
                                                </Badge>
                                            )}
                                        </Group>
                                    ))}
                                </Stack>
                            </div>
                        )}
                    </Stack>
                ) : (
                    <Text c="#52525b" ff="Inter" ta="center" py="xl">
                        No part information available
                    </Text>
                )}
            </div>
        </Modal>
    );
}

// Add pulse animation styles to document
if (typeof document !== 'undefined') {
    const style = document.createElement('style');
    style.textContent = `
    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.6; }
    }
  `;
    document.head.appendChild(style);
}