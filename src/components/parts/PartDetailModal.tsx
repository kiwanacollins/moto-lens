import { Modal, Title, Text, Group, Button, Stack, Code, Badge, Image, List, ThemeIcon } from '@mantine/core';
import { MdClose, MdCheckCircle } from 'react-icons/md';
import type { PartInfo, Hotspot } from '../../types/parts';
import type { PartDetailsResponse } from '../../services/partsService';

/**
 * Parse markdown-like AI response and convert to structured sections
 */
function parseAIDescription(description: string): { 
    sections: Array<{ title: string; content: string[] }>;
    rawText: string;
} {
    if (!description) {
        return { sections: [], rawText: '' };
    }

    const sections: Array<{ title: string; content: string[] }> = [];
    
    // Split by common markdown section patterns
    const lines = description.split('\n').map(line => line.trim()).filter(Boolean);
    
    let currentSection: { title: string; content: string[] } | null = null;
    
    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        
        // Check for inline header: **Header:** content (most common pattern)
        const inlineHeaderMatch = line.match(/^\*\*([^*]+)\*\*:?\s*(.*)$/);
        if (inlineHeaderMatch) {
            // Save previous section
            if (currentSection) {
                sections.push(currentSection);
            }
            
            const title = inlineHeaderMatch[1].trim();
            const firstLineContent = inlineHeaderMatch[2].trim();
            
            currentSection = { title, content: [] };
            
            // Add the content from the same line if any
            if (firstLineContent) {
                currentSection.content.push(cleanMarkdown(firstLineContent));
            }
            continue;
        }
        
        // Check if this line is a standalone section header (starts with ** and ends with **)
        const headerMatch = line.match(/^\*\*([^*]+)\*\*:?\s*$/);
        if (headerMatch) {
            if (currentSection) {
                sections.push(currentSection);
            }
            currentSection = { title: headerMatch[1].trim(), content: [] };
            continue;
        }
        
        // Regular content line
        if (currentSection) {
            // Clean up bullet markers and markdown
            const cleanedLine = cleanMarkdown(line.replace(/^[\*\-•]\s*/, '').trim());
            if (cleanedLine) {
                // Break long content into shorter sentences for better readability
                const sentences = cleanedLine.split(/\.\s+/).filter(s => s.trim().length > 0);
                sentences.forEach((sentence, index) => {
                    const formattedSentence = sentence.trim() + (index < sentences.length - 1 ? '.' : '');
                    if (formattedSentence.length > 5) {
                        currentSection!.content.push(formattedSentence);
                    }
                });
            }
        } else {
            // No section yet, create a general one
            const cleanedLine = cleanMarkdown(line);
            if (cleanedLine) {
                currentSection = { title: 'Overview', content: [cleanedLine] };
            }
        }
    }
    
    // Don't forget the last section
    if (currentSection) {
        sections.push(currentSection);
    }
    
    // Filter out empty sections and sort to prioritize components first
    const filteredSections = sections.filter(section => section.content.length > 0);
    
    filteredSections.sort((a, b) => {
        const aIsComponents = a.title.toLowerCase().includes('component') || 
                             a.title.toLowerCase().includes('parts') ||
                             a.title.toLowerCase().includes('main');
        const bIsComponents = b.title.toLowerCase().includes('component') || 
                             b.title.toLowerCase().includes('parts') ||
                             b.title.toLowerCase().includes('main');
        
        if (aIsComponents && !bIsComponents) return -1;
        if (!aIsComponents && bIsComponents) return 1;
        return 0;
    });
    
    return { sections: filteredSections, rawText: description };
}

/**
 * Clean markdown formatting from text
 */
function cleanMarkdown(text: string): string {
    return text
        .replace(/\*\*([^*]+)\*\*/g, '$1') // Remove bold **text**
        .replace(/\*([^*]+)\*/g, '$1')     // Remove italic *text*
        .replace(/`([^`]+)`/g, '$1')       // Remove inline code
        .replace(/^\s*[\*\-•]\s*/, '')     // Remove leading bullets
        .trim();
}

interface PartDetailModalProps {
    opened: boolean;
    onClose: () => void;
    partInfo: PartInfo | null;
    clickedHotspot: Hotspot | null;
    loading?: boolean;
    partDetails?: PartDetailsResponse | null;
}

export function PartDetailModal({
    opened,
    onClose,
    partInfo,
    clickedHotspot: _clickedHotspot,
    loading = false,
    partDetails
}: PartDetailModalProps) {
    return (
        <Modal
            opened={opened}
            onClose={onClose}
            size="lg"
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
                    width: '115% !important', // 15% wider
                    maxWidth: 'min(95vw, 600px)', // Responsive max width
                },
                body: {
                    padding: 0,
                },
                inner: {
                    minHeight: '67.5vh', // 35% taller (50vh * 1.35)
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

            {/* White content area - scrollable */}
            <div
                style={{
                    backgroundColor: '#ffffff',
                    padding: '34px', // Slightly more padding for larger modal
                    borderBottomLeftRadius: '8px',
                    borderBottomRightRadius: '8px',
                    maxHeight: '95vh', // Increased to accommodate larger modal
                    overflowY: 'auto',
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
                        {/* Part Image - if available from SerpApi */}
                        {partDetails?.image && (
                            <div>
                                <Image
                                    src={partDetails.image.url}
                                    alt={partDetails.image.title || partInfo.name}
                                    height={200}
                                    fit="contain"
                                    radius="md"
                                    style={{
                                        backgroundColor: '#f8fafc',
                                        border: '1px solid #e4e4e7',
                                    }}
                                    fallbackSrc="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZjRmNGY1Ii8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNiIgZmlsbD0iIzUyNTI1YiIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9IjAuM2VtIj5ObyBJbWFnZSBBdmFpbGFibGU8L3RleHQ+PC9zdmc+"
                                />
                                {partDetails.image.title && (
                                    <Text size="xs" c="#71717a" ff="Inter" mt="xs" ta="center">
                                        {partDetails.image.title}
                                    </Text>
                                )}
                            </div>
                        )}

                        {/* Function description - Parsed AI content */}
                        {partInfo.description && (
                            <div>
                                <Text c="#0a0a0a" ff="Inter" fw={600} size="sm" mb="xs">
                                    Function & Description
                                </Text>
                                {(() => {
                                    const { sections } = parseAIDescription(partInfo.description);
                                    
                                    if (sections.length > 0) {
                                        return (
                                            <Stack gap="md">
                                                {sections.map((section, sectionIndex) => (
                                                    <div key={sectionIndex}>
                                                        {/* Section title */}
                                                        <Text 
                                                            c="#0ea5e9" 
                                                            ff="Inter" 
                                                            fw={600} 
                                                            size="xs" 
                                                            tt="uppercase"
                                                            mb={4}
                                                            style={{ letterSpacing: '0.5px' }}
                                                        >
                                                            {section.title}
                                                        </Text>
                                                        
                                                        {/* Section content */}
                                                        {section.content.length === 1 ? (
                                                            <Text 
                                                                c="#52525b" 
                                                                ff="Inter" 
                                                                size="sm" 
                                                                style={{ lineHeight: 1.6 }}
                                                            >
                                                                {section.content[0]}
                                                            </Text>
                                                        ) : (
                                                            <List
                                                                spacing="xs"
                                                                size="sm"
                                                                icon={
                                                                    <ThemeIcon color="blue.4" size={16} radius="xl">
                                                                        <MdCheckCircle size={10} />
                                                                    </ThemeIcon>
                                                                }
                                                            >
                                                                {section.content.map((item, itemIndex) => (
                                                                    <List.Item key={itemIndex}>
                                                                        <Text 
                                                                            c="#52525b" 
                                                                            ff="Inter" 
                                                                            size="sm" 
                                                                            style={{ lineHeight: 1.5 }}
                                                                        >
                                                                            {item}
                                                                        </Text>
                                                                    </List.Item>
                                                                ))}
                                                            </List>
                                                        )}
                                                    </div>
                                                ))}
                                            </Stack>
                                        );
                                    }
                                    
                                    // Fallback: plain text if parsing fails
                                    return (
                                        <Text c="#52525b" ff="Inter" size="sm" style={{ lineHeight: 1.6 }}>
                                            {cleanMarkdown(partInfo.description)}
                                        </Text>
                                    );
                                })()}
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
                                                {cleanMarkdown(symptom)}
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