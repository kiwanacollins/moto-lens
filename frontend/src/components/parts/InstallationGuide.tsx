import { Paper, Stack, Text, Group, Badge, Button, Timeline, Alert } from '@mantine/core';
import { MdConstruction, MdTimer, MdWarning, MdCheckCircle, MdArrowForward } from 'react-icons/md';
import { FiTool, FiAlertTriangle, FiClock } from 'react-icons/fi';

interface InstallationStep {
    id: number;
    title: string;
    description: string;
    estimatedTime: string;
    difficulty: 'easy' | 'moderate' | 'expert';
    tools: string[];
    warnings?: string[];
    tips?: string;
}

interface InstallationGuideProps {
    partName: string;
    vehicleModel: string;
    totalTime: string;
    difficulty: 'easy' | 'moderate' | 'expert';
    steps: InstallationStep[];
    requiredTools: string[];
    safetyWarnings: string[];
}

export function InstallationGuide({
    partName,
    vehicleModel,
    totalTime,
    difficulty,
    steps,
    requiredTools,
    safetyWarnings
}: InstallationGuideProps) {

    // Difficulty configuration
    const getDifficultyConfig = (level: string) => {
        switch (level) {
            case 'easy':
                return {
                    color: '#10b981',
                    label: 'Easy',
                    bgColor: '#10b98115',
                    icon: FiTool,
                };
            case 'moderate':
                return {
                    color: '#f59e0b',
                    label: 'Moderate',
                    bgColor: '#f59e0b15',
                    icon: MdConstruction,
                };
            case 'expert':
                return {
                    color: '#ef4444',
                    label: 'Expert',
                    bgColor: '#ef444415',
                    icon: MdConstruction,
                };
            default:
                return {
                    color: '#6b7280',
                    label: 'Unknown',
                    bgColor: '#6b728015',
                    icon: FiTool,
                };
        }
    };

    const difficultyConfig = getDifficultyConfig(difficulty);
    const DifficultyIcon = difficultyConfig.icon;

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
            {/* Red dot and connecting line */}
            <div
                style={{
                    position: 'absolute',
                    top: '16px',
                    left: '16px',
                    width: '12px',
                    height: '12px',
                    backgroundColor: '#ef4444',
                    borderRadius: '50%',
                    boxShadow: '0 2px 4px rgba(239, 68, 68, 0.3)',
                }}
            />
            <div
                style={{
                    position: 'absolute',
                    top: '22px',
                    left: '28px',
                    width: '32px',
                    height: '2px',
                    backgroundColor: '#ef4444',
                }}
            />

            <Stack gap="lg" style={{ marginLeft: '40px' }}>
                {/* Header */}
                <div>
                    <Group justify="space-between" align="flex-start" mb="sm">
                        <div>
                            <Text ff="Inter" fw={600} size="lg" c="#0a0a0a">
                                Installation Guide
                            </Text>
                            <Text ff="Inter" size="sm" c="#52525b">
                                {partName} • {vehicleModel}
                            </Text>
                        </div>

                        <Group gap="sm">
                            <Badge
                                leftSection={<MdTimer size={14} />}
                                variant="light"
                                color="blue"
                                size="lg"
                                ff="Inter"
                            >
                                {totalTime}
                            </Badge>

                            <Badge
                                leftSection={<DifficultyIcon size={14} />}
                                variant="light"
                                size="lg"
                                ff="Inter"
                                style={{
                                    backgroundColor: difficultyConfig.bgColor,
                                    color: difficultyConfig.color,
                                }}
                            >
                                {difficultyConfig.label}
                            </Badge>
                        </Group>
                    </Group>

                    {/* Overview Stats */}
                    <Group gap="lg">
                        <Group gap="xs" align="center">
                            <div
                                style={{
                                    width: '8px',
                                    height: '8px',
                                    backgroundColor: '#ef4444',
                                    borderRadius: '50%',
                                }}
                            />
                            <Text ff="Inter" size="sm" c="#52525b">
                                {steps.length} Steps
                            </Text>
                        </Group>

                        <Group gap="xs" align="center">
                            <div
                                style={{
                                    width: '8px',
                                    height: '8px',
                                    backgroundColor: '#ef4444',
                                    borderRadius: '50%',
                                }}
                            />
                            <Text ff="Inter" size="sm" c="#52525b">
                                {requiredTools.length} Tools Required
                            </Text>
                        </Group>
                    </Group>
                </div>

                {/* Safety Warnings */}
                {safetyWarnings.length > 0 && (
                    <Alert
                        icon={<MdWarning size={20} />}
                        title="Safety Warnings"
                        color="red"
                        variant="light"
                        radius="sm"
                    >
                        <Stack gap="xs">
                            {safetyWarnings.map((warning, index) => (
                                <Group key={index} gap="xs" align="flex-start">
                                    <FiAlertTriangle size={14} style={{ color: '#ef4444', marginTop: '2px', flexShrink: 0 }} />
                                    <Text ff="Inter" size="sm" style={{ lineHeight: 1.4 }}>
                                        {warning}
                                    </Text>
                                </Group>
                            ))}
                        </Stack>
                    </Alert>
                )}

                {/* Required Tools */}
                <Paper bg="#f4f4f5" p="md" radius="sm" style={{ border: '1px solid #e4e4e7' }}>
                    <Group gap="xs" align="center" mb="sm">
                        <div
                            style={{
                                width: '8px',
                                height: '8px',
                                backgroundColor: '#ef4444',
                                borderRadius: '50%',
                            }}
                        />
                        <Text ff="Inter" fw={600} size="sm" c="#0a0a0a">
                            Required Tools
                        </Text>
                    </Group>

                    <Group gap="xs">
                        {requiredTools.map((tool, index) => (
                            <Badge
                                key={index}
                                leftSection={<FiTool size={12} />}
                                variant="light"
                                color="gray"
                                size="sm"
                                ff="Inter"
                            >
                                {tool}
                            </Badge>
                        ))}
                    </Group>
                </Paper>

                {/* Installation Steps with Timeline */}
                <div>
                    <Group gap="xs" align="center" mb="md">
                        <div
                            style={{
                                width: '8px',
                                height: '8px',
                                backgroundColor: '#ef4444',
                                borderRadius: '50%',
                            }}
                        />
                        <Text ff="Inter" fw={600} size="md" c="#0a0a0a">
                            Step-by-Step Instructions
                        </Text>
                    </Group>

                    <Timeline
                        active={-1}
                        bulletSize={24}
                        lineWidth={3}
                        color="blue.4"
                        styles={{
                            itemBullet: {
                                backgroundColor: '#0ea5e9',
                                border: '2px solid #ffffff',
                                boxShadow: '0 2px 4px rgba(14, 165, 233, 0.3)',
                            },
                            itemBody: {
                                marginLeft: '8px',
                            },
                            item: {
                                paddingBottom: '20px',
                            },
                        }}
                    >
                        {steps.map((step, index) => {
                            const stepDifficulty = getDifficultyConfig(step.difficulty);

                            return (
                                <Timeline.Item
                                    key={step.id}
                                    bullet={
                                        <Text ff="Inter" fw={600} size="sm" c="white">
                                            {step.id}
                                        </Text>
                                    }
                                    title={
                                        <Group gap="sm" align="center">
                                            <Text ff="Inter" fw={600} size="md" c="#0a0a0a">
                                                {step.title}
                                            </Text>
                                            <Badge
                                                size="sm"
                                                variant="dot"
                                                color="gray"
                                                ff="Inter"
                                            >
                                                {step.estimatedTime}
                                            </Badge>
                                        </Group>
                                    }
                                >
                                    <Paper
                                        bg="#ffffff"
                                        p="md"
                                        radius="sm"
                                        style={{
                                            border: '1px solid #e4e4e7',
                                            borderLeft: `3px solid ${stepDifficulty.color}`,
                                            position: 'relative',
                                        }}
                                    >
                                        {/* Arrow from timeline */}
                                        <div
                                            style={{
                                                position: 'absolute',
                                                top: '50%',
                                                left: '-12px',
                                                width: '8px',
                                                height: '2px',
                                                backgroundColor: '#0ea5e9',
                                                transform: 'translateY(-50%)',
                                            }}
                                        />

                                        <Stack gap="sm">
                                            <Text ff="Inter" size="sm" c="#52525b" style={{ lineHeight: 1.5 }}>
                                                {step.description}
                                            </Text>

                                            {/* Tools for this step */}
                                            {step.tools.length > 0 && (
                                                <Group gap="xs">
                                                    <Text ff="Inter" size="xs" c="#52525b" fw={500}>
                                                        Tools:
                                                    </Text>
                                                    {step.tools.map((tool, toolIndex) => (
                                                        <Badge
                                                            key={toolIndex}
                                                            size="xs"
                                                            variant="outline"
                                                            color="gray"
                                                            ff="Inter"
                                                        >
                                                            {tool}
                                                        </Badge>
                                                    ))}
                                                </Group>
                                            )}

                                            {/* Warnings for this step */}
                                            {step.warnings && step.warnings.length > 0 && (
                                                <Stack gap="xs">
                                                    {step.warnings.map((warning, warnIndex) => (
                                                        <Group key={warnIndex} gap="xs" align="flex-start">
                                                            <MdWarning size={14} style={{ color: '#ef4444', marginTop: '2px', flexShrink: 0 }} />
                                                            <Text ff="Inter" size="xs" c="#ef4444" style={{ lineHeight: 1.4 }}>
                                                                {warning}
                                                            </Text>
                                                        </Group>
                                                    ))}
                                                </Stack>
                                            )}

                                            {/* Tips */}
                                            {step.tips && (
                                                <Group gap="xs" align="flex-start">
                                                    <MdCheckCircle size={14} style={{ color: '#10b981', marginTop: '2px', flexShrink: 0 }} />
                                                    <Text ff="Inter" size="xs" c="#10b981" style={{ lineHeight: 1.4 }}>
                                                        <strong>Tip:</strong> {step.tips}
                                                    </Text>
                                                </Group>
                                            )}
                                        </Stack>
                                    </Paper>

                                    {/* Next step arrow */}
                                    {index < steps.length - 1 && (
                                        <Group gap="xs" align="center" mt="sm" justify="center">
                                            <MdArrowForward size={16} style={{ color: '#0ea5e9' }} />
                                            <Text ff="Inter" size="xs" c="#0ea5e9" fw={500}>
                                                Next Step
                                            </Text>
                                        </Group>
                                    )}
                                </Timeline.Item>
                            );
                        })}
                    </Timeline>
                </div>

                {/* Completion Actions */}
                <Paper bg="#10b98115" p="md" radius="sm" style={{ border: '1px solid #10b98130' }}>
                    <Group justify="space-between" align="center">
                        <div>
                            <Text ff="Inter" fw={600} size="sm" c="#0a0a0a">
                                Installation Complete
                            </Text>
                            <Text ff="Inter" size="sm" c="#52525b">
                                Test part functionality and check all connections
                            </Text>
                        </div>

                        <Group gap="sm">
                            <Button
                                leftSection={<FiClock size={16} />}
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
                                Set Reminder
                            </Button>

                            <Button
                                leftSection={<MdCheckCircle size={16} />}
                                color="blue.4"
                                variant="filled"
                                size="sm"
                                ff="Inter"
                                fw={500}
                                style={{
                                    backgroundColor: '#0ea5e9',
                                    minHeight: '44px',
                                }}
                            >
                                Mark Complete
                            </Button>
                        </Group>
                    </Group>
                </Paper>
            </Stack>
        </Paper>
    );
}

export default InstallationGuide;