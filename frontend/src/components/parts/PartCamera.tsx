/**
 * Camera Component for Part Scanning
 *
 * Provides camera capture functionality for analyzing spare parts
 * with professional MotoLens design
 */

import { useState, useRef, useCallback, useEffect } from 'react';
import {
    Modal,
    Paper,
    Group,
    Button,
    Stack,
    Text,
    Center,
    Box,
    ActionIcon,
    Progress,
    ThemeIcon,
} from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { notifications } from '@mantine/notifications';
import { MdCameraAlt, MdFlip, MdClose, MdPhotoCamera, MdUpload } from 'react-icons/md';
import { FiCamera, FiRotateCcw } from 'react-icons/fi';

interface PartCameraProps {
    onImageCapture: (file: File) => void;
    isProcessing?: boolean;
    children?: React.ReactNode;
}

interface CameraState {
    stream: MediaStream | null;
    facingMode: 'user' | 'environment';
    flashEnabled: boolean;
    isInitializing: boolean;
    error: string | null;
}

export const PartCamera: React.FC<PartCameraProps> = ({
    onImageCapture,
    isProcessing = false,
    children,
}) => {
    const [opened, { open, close }] = useDisclosure(false);
    const [cameraState, setCameraState] = useState<CameraState>({
        stream: null,
        facingMode: 'environment', // Default to rear camera for part scanning
        flashEnabled: false,
        isInitializing: false,
        error: null,
    });

    const videoRef = useRef<HTMLVideoElement>(null);
    const canvasRef = useRef<HTMLCanvasElement>(null);
    const fileInputRef = useRef<HTMLInputElement>(null);

    // Camera permissions and initialization
    const initializeCamera = useCallback(async () => {
        setCameraState(prev => ({ ...prev, isInitializing: true, error: null }));

        try {
            const constraints: MediaStreamConstraints = {
                video: {
                    facingMode: cameraState.facingMode,
                    width: { ideal: 1920 },
                    height: { ideal: 1080 },
                },
            };

            const stream = await navigator.mediaDevices.getUserMedia(constraints);

            if (videoRef.current) {
                videoRef.current.srcObject = stream;
            }

            setCameraState(prev => ({
                ...prev,
                stream,
                isInitializing: false,
                error: null,
            }));
        } catch (error) {
            console.error('Camera initialization error:', error);
            setCameraState(prev => ({
                ...prev,
                isInitializing: false,
                error: 'Camera access denied. Please allow camera permissions and try again.',
            }));
        }
    }, [cameraState.facingMode]);

    // Cleanup camera stream
    const cleanup = useCallback(() => {
        setCameraState(prev => {
            if (prev.stream) {
                prev.stream.getTracks().forEach(track => track.stop());
            }
            return { ...prev, stream: null };
        });
    }, []);

    // Handle modal state changes
    useEffect(() => {
        let mounted = true;

        if (opened && !cameraState.stream && !cameraState.error) {
            // Initialize camera asynchronously to avoid setState in effect
            const initAsync = async () => {
                if (mounted) {
                    await initializeCamera();
                }
            };
            void initAsync();
        }

        return () => {
            mounted = false;
        };
    }, [opened, cameraState.stream, cameraState.error, initializeCamera]);

    // Cleanup when modal closes
    useEffect(() => {
        if (!opened && cameraState.stream) {
            // Use setTimeout to avoid direct setState in effect
            const timeoutId = setTimeout(() => {
                cleanup();
            }, 0);
            return () => clearTimeout(timeoutId);
        }
    }, [opened, cameraState.stream, cleanup]);

    // Capture photo
    const capturePhoto = useCallback(() => {
        if (!videoRef.current || !canvasRef.current) return;

        const video = videoRef.current;
        const canvas = canvasRef.current;
        const context = canvas.getContext('2d');

        if (!context) return;

        // Set canvas dimensions to video dimensions
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;

        // Draw current frame to canvas
        context.drawImage(video, 0, 0, canvas.width, canvas.height);

        // Convert to blob and file
        canvas.toBlob(
            blob => {
                if (blob) {
                    const file = new File([blob], `part-scan-${Date.now()}.jpg`, {
                        type: 'image/jpeg',
                    });

                    onImageCapture(file);
                    close();
                    cleanup();

                    notifications.show({
                        title: 'Photo captured',
                        message: 'Analyzing part...',
                        color: 'blue',
                        icon: <MdPhotoCamera />,
                    });
                }
            },
            'image/jpeg',
            0.9
        );
    }, [onImageCapture, close, cleanup]);

    // Switch camera (front/rear)
    const switchCamera = useCallback(() => {
        cleanup();
        setCameraState(prev => ({
            ...prev,
            facingMode: prev.facingMode === 'user' ? 'environment' : 'user',
        }));
    }, [cleanup]);

    // Handle file upload
    const handleFileUpload = useCallback(
        (event: React.ChangeEvent<HTMLInputElement>) => {
            const file = event.target.files?.[0];
            if (file) {
                onImageCapture(file);
                close();
                cleanup();

                notifications.show({
                    title: 'Image uploaded',
                    message: 'Analyzing part...',
                    color: 'blue',
                    icon: <MdUpload />,
                });
            }
        },
        [onImageCapture, close, cleanup]
    );

    return (
        <>
            {/* Trigger Button */}
            {children ? (
                <Box onClick={open} style={{ cursor: 'pointer' }}>
                    {children}
                </Box>
            ) : (
                <Button
                    leftSection={<FiCamera size={20} />}
                    variant="filled"
                    color="blue.4"
                    size="lg"
                    onClick={open}
                    loading={isProcessing}
                    disabled={isProcessing}
                    ff="Inter"
                    fw={600}
                    style={{
                        minWidth: '140px',
                        minHeight: '48px', // Larger touch target for mobile
                    }}
                >
                    Scan Part
                </Button>
            )}

            {/* Camera Modal */}
            <Modal
                opened={opened}
                onClose={close}
                size="xl"
                title="Scan Spare Part"
                centered
                overlayProps={{ backgroundOpacity: 0.9, blur: 3 }}
                styles={{
                    title: {
                        fontSize: '1.25rem',
                        fontWeight: 600,
                        color: '#0a0a0a',
                        fontFamily: 'Inter',
                    },
                }}
            >
                <Stack gap="md">
                    {/* Instructions */}
                    <Paper p="md" withBorder bg="blue.0">
                        <Text size="sm" c="dark.7" ff="Inter">
                            📱 <strong>Position the part clearly in frame</strong>
                            <br />
                            💡 Ensure good lighting and focus
                            <br />
                            🔍 Include any visible markings or damage
                        </Text>
                    </Paper>

                    {/* Camera View */}
                    <Paper withBorder radius="md" style={{ overflow: 'hidden', aspectRatio: '4/3' }}>
                        {cameraState.error ? (
                            <Center p="xl" style={{ aspectRatio: '4/3' }}>
                                <Stack align="center" gap="md">
                                    <ThemeIcon size="xl" color="red" variant="light">
                                        <MdClose size={24} />
                                    </ThemeIcon>
                                    <Text c="red" ta="center" ff="Inter">
                                        {cameraState.error}
                                    </Text>
                                    <Button
                                        variant="light"
                                        color="blue"
                                        onClick={initializeCamera}
                                        leftSection={<FiRotateCcw size={16} />}
                                    >
                                        Try Again
                                    </Button>
                                </Stack>
                            </Center>
                        ) : cameraState.isInitializing ? (
                            <Center p="xl" style={{ aspectRatio: '4/3' }}>
                                <Stack align="center" gap="md">
                                    <Progress value={100} animated size="sm" color="blue.4" w="80%" />
                                    <Text c="dark.6" ff="Inter">
                                        Initializing camera...
                                    </Text>
                                </Stack>
                            </Center>
                        ) : (
                            <Box pos="relative" w="100%" style={{ aspectRatio: '4/3' }}>
                                <video
                                    ref={videoRef}
                                    autoPlay
                                    playsInline
                                    muted
                                    style={{
                                        width: '100%',
                                        height: '100%',
                                        objectFit: 'cover',
                                    }}
                                />

                                {/* Camera Controls Overlay */}
                                <Group justify="space-between" pos="absolute" top="sm" left="sm" right="sm">
                                    <ActionIcon
                                        variant="filled"
                                        color="dark.9"
                                        size="xl"
                                        radius="xl"
                                        onClick={switchCamera}
                                        style={{
                                            minWidth: '48px',
                                            minHeight: '48px', // Larger touch target for mobile
                                        }}
                                    >
                                        <MdFlip color="white" size={20} />
                                    </ActionIcon>

                                    <Text
                                        size="xs"
                                        c="white"
                                        p="sm"
                                        bg="rgba(0,0,0,0.7)"
                                        style={{ borderRadius: '4px' }}
                                        ff="Inter"
                                        fw={500}
                                    >
                                        {cameraState.facingMode === 'environment' ? 'Rear Camera' : 'Front Camera'}
                                    </Text>
                                </Group>

                                {/* Capture Guide Overlay */}
                                <Center
                                    pos="absolute"
                                    top={0}
                                    left={0}
                                    right={0}
                                    bottom={0}
                                    style={{ pointerEvents: 'none' }}
                                >
                                    <Box
                                        w="80%"
                                        h="60%"
                                        style={{
                                            border: '2px solid #0ea5e9',
                                            borderRadius: '8px',
                                            backgroundColor: 'rgba(14, 165, 233, 0.1)',
                                        }}
                                    />
                                </Center>
                            </Box>
                        )}
                    </Paper>

                    {/* Action Buttons */}
                    <Group justify="center" gap="md" wrap="wrap">
                        {/* Capture Button */}
                        <Button
                            size="lg"
                            variant="filled"
                            color="blue.4"
                            onClick={capturePhoto}
                            disabled={!cameraState.stream || cameraState.error !== null}
                            leftSection={<MdCameraAlt size={20} />}
                            ff="Inter"
                            fw={600}
                            style={{
                                minWidth: '140px',
                                minHeight: '48px', // Larger touch target
                                flex: '1',
                            }}
                        >
                            Capture
                        </Button>

                        {/* Upload Button */}
                        <Button
                            size="lg"
                            variant="outline"
                            color="dark.9"
                            onClick={() => fileInputRef.current?.click()}
                            leftSection={<MdUpload size={20} />}
                            ff="Inter"
                            fw={600}
                            style={{
                                minWidth: '140px',
                                minHeight: '48px', // Larger touch target
                                flex: '1',
                            }}
                        >
                            Upload
                        </Button>
                    </Group>

                    {/* Alternative Text */}
                    <Text size="xs" c="dark.5" ta="center" ff="Inter">
                        You can also upload an existing photo from your device
                    </Text>
                </Stack>
            </Modal>

            {/* Hidden file input */}
            <input
                ref={fileInputRef}
                type="file"
                accept="image/jpeg,image/png,image/webp"
                style={{ display: 'none' }}
                onChange={handleFileUpload}
            />

            {/* Hidden canvas for image capture */}
            <canvas ref={canvasRef} style={{ display: 'none' }} />
        </>
    );
};

export default PartCamera;
