/**
 * Part Analysis Display Component
 *
 * Shows the results of Gemini vision analysis for spare parts
 * with professional MotoLens styling
 */

import { useState, useRef, useEffect } from 'react';
import {
  Paper,
  Stack,
  Text,
  Group,
  Button,
  Badge,
  Textarea,
  Alert,
  Loader,
  ThemeIcon,
  Modal,
  Divider,
} from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { notifications } from '@mantine/notifications';
import { MdCheckCircle, MdError, MdQuestionAnswer, MdInfo, MdSend } from 'react-icons/md';
import { FiTool, FiMessageCircle } from 'react-icons/fi';
import type {
  PartScanResult,
  PartQuestionResult,
  VehicleContext,
} from '../../services/partScanService';
import { askPartQuestion } from '../../services/partScanService';

interface PartAnalysisProps {
  result: PartScanResult | null;
  imageFile: File | null;
  vehicleContext?: VehicleContext;
  isLoading?: boolean;
  error?: string | null;
  onRetry?: () => void;
}

export const PartAnalysis: React.FC<PartAnalysisProps> = ({
  result,
  imageFile,
  vehicleContext,
  isLoading = false,
  error = null,
  onRetry,
}) => {
  const [questionModalOpened, { open: openQuestionModal, close: closeQuestionModal }] =
    useDisclosure(false);
  const [question, setQuestion] = useState('');
  const [questionResult, setQuestionResult] = useState<PartQuestionResult | null>(null);
  const [isAskingQuestion, setIsAskingQuestion] = useState(false);
  const [hasAnalysisScroll, setHasAnalysisScroll] = useState(false);
  const [hasQuestionScroll, setHasQuestionScroll] = useState(false);

  const analysisScrollRef = useRef<HTMLDivElement>(null);
  const questionScrollRef = useRef<HTMLDivElement>(null);

  // Check if content needs scrolling
  useEffect(() => {
    const checkScrollNeeded = () => {
      if (analysisScrollRef.current) {
        const { scrollHeight, clientHeight } = analysisScrollRef.current;
        setHasAnalysisScroll(scrollHeight > clientHeight);
      }

      if (questionScrollRef.current) {
        const { scrollHeight, clientHeight } = questionScrollRef.current;
        setHasQuestionScroll(scrollHeight > clientHeight);
      }
    };

    checkScrollNeeded();

    // Recheck when window resizes
    window.addEventListener('resize', checkScrollNeeded);
    return () => window.removeEventListener('resize', checkScrollNeeded);
  }, [result, questionResult]);

  // Handle asking a question about the part
  const handleAskQuestion = async () => {
    if (!imageFile || !question.trim()) return;

    setIsAskingQuestion(true);

    try {
      const response = await askPartQuestion(imageFile, question.trim(), vehicleContext);
      setQuestionResult(response);
      setQuestion('');

      // Close modal after successful response
      closeQuestionModal();

      notifications.show({
        title: 'Question answered',
        message: 'AI analysis complete',
        color: 'green',
        icon: <MdCheckCircle />,
      });

      // Scroll to show the answer after a brief delay
      setTimeout(() => {
        if (questionScrollRef.current) {
          questionScrollRef.current.scrollIntoView({ 
            behavior: 'smooth', 
            block: 'start' 
          });
        }
      }, 100);
    } catch (err) {
      console.error('Error asking question:', err);
      notifications.show({
        title: 'Error',
        message: err instanceof Error ? err.message : 'Failed to ask question',
        color: 'red',
        icon: <MdError />,
      });
    } finally {
      setIsAskingQuestion(false);
    }
  };

  // Format analysis text for better readability
  const formatAnalysis = (text: string) => {
    return text
      .split('\n')
      .map((line, index) => {
        const trimmed = line.trim();
        if (!trimmed) return null;

        // Header detection (lines with ** or capitalized sections)
        if (trimmed.match(/^\*\*.*\*\*$/)) {
          return (
            <Text key={index} fw={600} size="lg" c="dark.9" ff="Inter" mt="md">
              {trimmed.replace(/\*\*/g, '')}
            </Text>
          );
        }

        // Subheadings with bold asterisks (e.g., "* **Cracked or Damaged Insulator:**")
        if (trimmed.match(/^\*\s*\*\*.*\*\*.*$/)) {
          const match = trimmed.match(/^\*\s*\*\*(.*?)\*\*(.*)$/);
          if (match) {
            return (
              <Text key={index} fw={600} size="md" c="dark.9" ff="Inter" mt="sm">
                • <span style={{ fontWeight: 600 }}>{match[1]}:</span>
                <span style={{ fontWeight: 400 }}>{match[2]}</span>
              </Text>
            );
          }
        }

        // Bold text in middle of line (e.g., "Look at **this part** carefully")
        if (trimmed.includes('**')) {
          const parts = trimmed.split(/(\*\*[^*]+\*\*)/);
          return (
            <Text
              key={index}
              size="sm"
              c="dark.7"
              ff="Inter"
              style={{ lineHeight: 1.6 }}
              ml={trimmed.startsWith('*') ? 'md' : 0}
            >
              {parts.map((part, i) => {
                if (part.match(/^\*\*.*\*\*$/)) {
                  return (
                    <span key={i} style={{ fontWeight: 600 }}>
                      {part.replace(/\*\*/g, '')}
                    </span>
                  );
                }
                return part;
              })}
            </Text>
          );
        }

        // Bullet points
        if (trimmed.startsWith('•') || trimmed.startsWith('-') || trimmed.startsWith('*')) {
          return (
            <Text key={index} size="sm" c="dark.7" ff="Inter" ml="md" style={{ lineHeight: 1.6 }}>
              {trimmed.replace(/^\*\s*/, '• ')}
            </Text>
          );
        }

        // Regular text
        return (
          <Text key={index} size="sm" c="dark.7" ff="Inter" style={{ lineHeight: 1.6 }}>
            {trimmed}
          </Text>
        );
      })
      .filter(Boolean);
  };

  // Loading state
  if (isLoading) {
    return (
      <Paper shadow="sm" p="lg" radius="md" withBorder>
        <Group justify="center" gap="md">
          <Loader size="md" color="blue.4" />
          <Stack gap={4}>
            <Text fw={600} c="dark.9" ff="Inter">
              Analyzing part...
            </Text>
            <Text size="sm" c="dark.6" ff="Inter">
              This may take a few seconds
            </Text>
          </Stack>
        </Group>
      </Paper>
    );
  }

  // Error state
  if (error && !result) {
    return (
      <Alert icon={<MdError />} title="Analysis Failed" color="red" variant="light">
        <Stack gap="xs">
          <Text size="sm" ff="Inter">
            {error}
          </Text>
          {onRetry && (
            <Button
              variant="light"
              color="red"
              size="sm"
              onClick={onRetry}
              leftSection={<FiTool size={16} />}
            >
              Try Again
            </Button>
          )}
        </Stack>
      </Alert>
    );
  }

  // No result state
  if (!result) {
    return null;
  }

  return (
    <Stack gap="md" style={{ maxHeight: '100%', overflow: 'visible' }}>
      {/* Main Analysis Result */}
      <Paper shadow="sm" p="lg" radius="md" withBorder style={{ position: 'relative' }}>
        <Stack gap="md">
          {/* Header */}
          <Group justify="space-between">
            <Group gap="sm">
              <ThemeIcon size="md" color="green" variant="light">
                <MdCheckCircle size={18} />
              </ThemeIcon>
              <Text fw={600} size="lg" c="dark.9" ff="Inter">
                Part Analysis Complete
              </Text>
            </Group>
            <Badge variant="light" color="blue.4" ff="Inter">
              {result.model}
            </Badge>
          </Group>

          {/* Vehicle Context */}
          {vehicleContext && (
            <Alert icon={<MdInfo />} color="blue" variant="light">
              <Stack gap="xs">
                <Text size="sm" c="dark.7" ff="JetBrains Mono" fw={500}>
                  Vehicle Context: {vehicleContext.year} {vehicleContext.make}{' '}
                  {vehicleContext.model}
                  {vehicleContext.engine && ` • ${vehicleContext.engine}`}
                </Text>
                <Text size="xs" c="dark.6" ff="Inter" style={{ fontStyle: 'italic' }}>
                  Note: Analysis is based purely on the image, not influenced by vehicle context
                </Text>
              </Stack>
            </Alert>
          )}

          {/* Analysis Text */}
          {result.analysis && (
            <div className={`scrollable-container ${hasAnalysisScroll ? 'has-scroll' : ''}`}>
              <Paper
                ref={analysisScrollRef}
                p="md"
                withBorder
                bg="gray.0"
                className="scrollable-ai-content"
                style={{
                  maxHeight: '300px',
                  overflowY: 'auto',
                  overflowX: 'hidden',
                }}
              >
                <Stack gap="xs">{formatAnalysis(result.analysis)}</Stack>
              </Paper>
            </div>
          )}

          {/* Action Buttons */}
          <Group gap="sm" mt="md">
            <Button
              variant="light"
              color="blue.4"
              size="sm"
              leftSection={<MdQuestionAnswer size={16} />}
              onClick={openQuestionModal}
              disabled={!imageFile}
              ff="Inter"
              fw={500}
            >
              Ask Question
            </Button>
          </Group>
        </Stack>
      </Paper>

      {/* Question Result */}
      {questionResult && (
        <Paper shadow="sm" p="lg" radius="md" withBorder bg="blue.0">
          <Stack gap="md">
            <Group gap="sm">
              <ThemeIcon size="md" color="blue.4" variant="light">
                <FiMessageCircle size={18} />
              </ThemeIcon>
              <Text fw={600} size="md" c="dark.9" ff="Inter">
                Q: {questionResult.question}
              </Text>
            </Group>

            <Divider />

            {questionResult.answer && (
              <Stack gap="xs">
                <Text fw={500} c="dark.8" ff="Inter">
                  Answer:
                </Text>
                <div className={`scrollable-container ${hasQuestionScroll ? 'has-scroll' : ''}`}>
                  <Paper
                    ref={questionScrollRef}
                    p="sm"
                    withBorder
                    bg="white"
                    className="scrollable-ai-content"
                    style={{
                      maxHeight: '250px',
                      overflowY: 'auto',
                      overflowX: 'hidden',
                    }}
                  >
                    {formatAnalysis(questionResult.answer)}
                  </Paper>
                </div>
              </Stack>
            )}
          </Stack>
        </Paper>
      )}

      {/* Question Modal */}
      <Modal
        opened={questionModalOpened}
        onClose={closeQuestionModal}
        title="Ask a Question"
        size="md"
        centered
        styles={{
          title: {
            fontSize: '1.1rem',
            fontWeight: 600,
            color: '#0a0a0a',
            fontFamily: 'Inter',
          },
          body: {
            maxHeight: '70vh',
            overflowY: 'auto',
          },
        }}
      >
        <Stack gap="md">
          <Alert icon={<MdInfo />} color="blue" variant="light">
            <Text size="sm" ff="Inter">
              Ask any specific question about the part in this image. Our AI will analyze the image
              and provide a detailed answer.
            </Text>
          </Alert>

          <Textarea
            placeholder="e.g., What condition is this part in? What part number do I need? Is this part worn out?"
            value={question}
            onChange={e => setQuestion(e.target.value)}
            rows={3}
            maxLength={500}
            styles={{
              input: {
                fontFamily: 'Inter',
                fontSize: '0.875rem',
              },
            }}
          />

          <Text size="xs" c="dark.5" ff="Inter">
            {question.length}/500 characters
          </Text>

          <Group justify="end" gap="sm">
            <Button variant="subtle" color="dark.6" onClick={closeQuestionModal} ff="Inter">
              Cancel
            </Button>
            <Button
              variant="filled"
              color="blue.4"
              onClick={handleAskQuestion}
              loading={isAskingQuestion}
              disabled={!question.trim() || question.length < 3}
              leftSection={<MdSend size={16} />}
              ff="Inter"
              fw={600}
            >
              Ask Question
            </Button>
          </Group>
        </Stack>
      </Modal>
    </Stack>
  );
};

export default PartAnalysis;
