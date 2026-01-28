import {
  Modal,
  Title,
  Text,
  Group,
  Button,
  Stack,
  Code,
  Badge,
  Image,
  List,
  ThemeIcon,
} from '@mantine/core';
import { MdClose, MdCheckCircle } from 'react-icons/md';
import type { PartInfo, Hotspot } from '../../types/parts';
import type { PartDetailsResponse } from '../../services/partsService';

/**
 * Parse markdown-like AI response and convert to structured sections
 */
function parseAIDescription(description: string): {
  sections: Array<{ title: string; content: string[]; kind: 'bullets' | 'paragraphs' }>;
  rawText: string;
} {
  if (!description) {
    return { sections: [], rawText: '' };
  }

  const sections: Array<{ title: string; content: string[]; kind: 'bullets' | 'paragraphs' }> = [];

  // Keep blank lines to preserve paragraph intent
  const lines = description.split('\n').map(l => l.replace(/\r/g, ''));

  let currentSection: { title: string; content: string[]; kind: 'bullets' | 'paragraphs' } | null =
    null;

  const pushCurrent = () => {
    if (!currentSection) return;
    // Remove empty content lines
    currentSection.content = currentSection.content.map(c => c.trim()).filter(Boolean);
    if (currentSection.content.length === 0) return;
    sections.push(currentSection);
  };

  for (const rawLine of lines) {
    const line = rawLine.trim();

    // Paragraph separator
    if (!line) {
      if (currentSection?.kind === 'paragraphs') {
        currentSection.content.push('');
      }
      continue;
    }

    // Header on its own line: **Header**
    const headerOnly = line.match(/^\*\*([^*]+)\*\*:?\s*$/);
    if (headerOnly) {
      pushCurrent();
      currentSection = { title: cleanMarkdown(headerOnly[1]).trim(), content: [], kind: 'bullets' };
      continue;
    }

    // Inline header: **Engine:** blah blah
    const headerInline = line.match(/^\*\*([^*]+)\*\*\s*:?\s*(.+)$/);
    if (headerInline) {
      pushCurrent();
      const title = cleanMarkdown(headerInline[1]).trim();
      const rest = cleanMarkdown(headerInline[2]).trim();
      // These sections are typically paragraph-style (like Technical Overview)
      currentSection = { title, content: [rest], kind: 'paragraphs' };
      continue;
    }

    // Bullet line?
    const isBullet = /^([\*\-•]|\d+\.)\s+/.test(line);
    const cleaned = cleanMarkdown(line.replace(/^([\*\-•]|\d+\.)\s+/, ''));

    if (!currentSection) {
      currentSection = {
        title: 'Overview',
        content: [],
        kind: isBullet ? 'bullets' : 'paragraphs',
      };
    }

    // If the section started as bullets but we see a paragraph-like line, switch to paragraphs
    if (!isBullet && currentSection.kind === 'bullets' && currentSection.content.length > 0) {
      currentSection.kind = 'paragraphs';
    }

    currentSection.content.push(cleaned);
  }

  pushCurrent();

  // Prioritize components-style sections first (keep relative order otherwise)
  const isComponentsTitle = (t: string) => {
    const s = t.toLowerCase();
    return (
      s.includes('component') ||
      s.includes('subpart') ||
      s.includes('sub-part') ||
      s.includes('made up') ||
      s === 'parts'
    );
  };
  const components = sections.filter(s => isComponentsTitle(s.title));
  const others = sections.filter(s => !isComponentsTitle(s.title));

  return { sections: [...components, ...others], rawText: description };
}

/**
 * Clean markdown formatting from text
 */
function cleanMarkdown(text: string): string {
  return text
    .replace(/\*\*([^*]+)\*\*/g, '$1') // Remove bold **text**
    .replace(/\*([^*]+)\*/g, '$1') // Remove italic *text*
    .replace(/`([^`]+)`/g, '$1') // Remove inline code
    .replace(/^\s*[\*\-•]\s*/, '') // Remove leading bullets
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
  partDetails,
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
          <Title order={3} c="white" ff="Inter" fw={600} size="lg" style={{ margin: 0 }}>
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
                            {section.kind === 'paragraphs' ? (
                              <Stack gap={6}>
                                {section.content
                                  .reduce<string[]>((acc, cur) => {
                                    // Merge consecutive lines into paragraphs, with '' as separator
                                    if (cur === '') {
                                      acc.push('');
                                      return acc;
                                    }
                                    const last = acc[acc.length - 1];
                                    if (acc.length === 0 || last === '') {
                                      acc.push(cur);
                                      return acc;
                                    }
                                    acc[acc.length - 1] = `${last} ${cur}`;
                                    return acc;
                                  }, [])
                                  .map(p => p.trim())
                                  .filter(Boolean)
                                  .map((paragraph, paragraphIndex) => (
                                    <Text
                                      key={paragraphIndex}
                                      c="#52525b"
                                      ff="Inter"
                                      size="sm"
                                      style={{ lineHeight: 1.6 }}
                                    >
                                      {paragraph}
                                    </Text>
                                  ))}
                              </Stack>
                            ) : section.content.length === 1 ? (
                              <Text c="#52525b" ff="Inter" size="sm" style={{ lineHeight: 1.6 }}>
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
                        <Badge variant="light" color="blue.4" size="sm" ff="Inter" fw={500}>
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
