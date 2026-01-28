/**
 * Camera Component for Part Scanning
 *
 * Provides camera capture functionality for analyzing spare parts
 * with professional MotoLens design
 *
 * Mobile-optimized for direct camera access on phones
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
    Divider,
} from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { notifications } from '@mantine/notifications';
import {
    MdCameraAlt,
    MdFlip,
    MdClose,
    MdPhotoCamera,
    MdUpload,
    MdPhotoLibrary,
} from 'react-icons/md';
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
    hasMultipleCameras: boolean;
}

// Check if device is mobile
const isMobileDevice = () => {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
};

// Check if mediaDevices API is available
const hasMediaDevices = () => {
    return !!(navigator.mediaDevices && navigator.mediaDevices.getUserMedia);
};

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
        hasMultipleCameras: false,
    });
    const [isMobile] = useState(isMobileDevice());

    const videoRef = useRef<HTMLVideoElement>(null);
    const canvasRef = useRef<HTMLCanvasElement>(null);
    const fileInputRef = useRef<HTMLInputElement>(null);
    const cameraInputRef = useRef<HTMLInputElement>(null);

    // Check for multiple cameras
    const checkMultipleCameras = useCallback(async () => {
        try {
            const devices = await navigator.mediaDevices.enumerateDevices();
            const videoDevices = devices.filter(device => device.kind === 'videoinput');
            setCameraState(prev => ({ ...prev, hasMultipleCameras: videoDevices.length > 1 }));
        } catch {
            // Silently fail - we'll assume single camera
        }
    }, []);

    // Camera permissions and initialization
    const initializeCamera = useCallback(async () => {
        if (!hasMediaDevices()) {
            setCameraState(prev => ({
                ...prev,
                isInitializing: false,
                error:
                    'Camera not supported. Please use the "Take Photo" button below to capture directly.',
            }));
            return;
        }

        setCameraState(prev => ({ ...prev, isInitializing: true, error: null }));

        try {
            const constraints: MediaStreamConstraints = {
                video: {
                    facingMode: cameraState.facingMode,
                    width: { ideal: 1920, min: 640 },
                    height: { ideal: 1080, min: 480 },
                },
                audio: false,
            };

            const stream = await navigator.mediaDevices.getUserMedia(constraints);

            if (videoRef.current) {
                videoRef.current.srcObject = stream;
                // Wait for video to be ready
                await new Promise<void>(resolve => {
                    if (videoRef.current) {
                        videoRef.current.onloadedmetadata = () => resolve();
                    }
                });
            }

            setCameraState(prev => ({
                ...prev,
                stream,
                isInitializing: false,
                error: null,
            }));

            // Check for multiple cameras after successful initialization
            await checkMultipleCameras();
        } catch (error) {
            console.error('Camera initialization error:', error);
            let errorMessage = 'Camera access denied. Please allow camera permissions and try again.';

            if (error instanceof Error) {
                if (error.name === 'NotAllowedError' || error.name === 'PermissionDeniedError') {
                    errorMessage =
                        'Camera permission denied. Please enable camera access in your browser settings.';
                } else if (error.name === 'NotFoundError' || error.name === 'DevicesNotFoundError') {
                    errorMessage = 'No camera found. Please use the "Take Photo" or "Upload" buttons below.';
                } else if (error.name === 'NotReadableError' || error.name === 'TrackStartError') {
                    errorMessage =
                        'Camera is in use by another app. Please close other camera apps and try again.';
                } else if (error.name === 'OverconstrainedError') {
                    errorMessage = 'Camera constraints not supported. Trying with basic settings...';
                    // Retry with basic constraints
                    try {
                        const basicStream = await navigator.mediaDevices.getUserMedia({ video: true });
                        if (videoRef.current) {
                            videoRef.current.srcObject = basicStream;
                        }
                        setCameraState(prev => ({
                            ...prev,
                            stream: basicStream,
                            isInitializing: false,
                            error: null,
                        }));
                        return;
                    } catch {
                        errorMessage = 'Camera initialization failed. Please use the upload option.';
                    }
                }
            }

            setCameraState(prev => ({
                ...prev,
                isInitializing: false,
                error: errorMessage,
            }));
        }
    }, [cameraState.facingMode, checkMultipleCameras]);

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
    const switchCamera = useCallback(async () => {
        // Stop current stream
        if (cameraState.stream) {
            cameraState.stream.getTracks().forEach(track => track.stop());
        }

        const newFacingMode = cameraState.facingMode === 'user' ? 'environment' : 'user';

        setCameraState(prev => ({
            ...prev,
            stream: null,
            facingMode: newFacingMode,
        }));

        // Re-initialize with new facing mode
        try {
            const constraints: MediaStreamConstraints = {
                video: {
                    facingMode: newFacingMode,
                    width: { ideal: 1920, min: 640 },
                    height: { ideal: 1080, min: 480 },
                },
                audio: false,
            };

            const stream = await navigator.mediaDevices.getUserMedia(constraints);

            if (videoRef.current) {
                videoRef.current.srcObject = stream;
            }

            setCameraState(prev => ({
                ...prev,
                stream,
                error: null,
            }));
        } catch (error) {
            console.error('Camera switch error:', error);
            setCameraState(prev => ({
                ...prev,
                error: 'Failed to switch camera. Please try again.',
            }));
        }
    }, [cameraState.stream, cameraState.facingMode]);

    // Handle direct camera capture (mobile-friendly)
    const handleDirectCapture = useCallback(
        (event: React.ChangeEvent<HTMLInputElement>) => {
            const file = event.target.files?.[0];
            if (file) {
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
            // Reset input value to allow capturing the same image again
            event.target.value = '';
        },
        [onImageCapture, close, cleanup]
    );

    // Handle file upload from gallery
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
            // Reset input value to allow uploading the same image again
            event.target.value = '';
        },
        [onImageCapture, close, cleanup]
    );

    // Trigger native camera on mobile
    const openNativeCamera = useCallback(() => {
        cameraInputRef.current?.click();
    }, []);

    // Trigger file picker
    const openFilePicker = useCallback(() => {
        fileInputRef.current?.click();
    }, []);

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

                    {/* Mobile Direct Capture Options */}
                    {isMobile && (
                        <Paper p="md" withBorder radius="md" bg="gray.0">
                            <Stack gap="sm">
                                <Text size="sm" fw={600} c="dark.7" ff="Inter" ta="center">
                                    📷 Quick Capture Options
                                </Text>
                                <Group grow>
                                    <Button
                                        size="lg"
                                        variant="filled"
                                        color="blue.5"
                                        onClick={openNativeCamera}
                                        leftSection={<MdCameraAlt size={18} />}
                                        ff="Inter"
                                        fw={600}
                                        style={{
                                            minHeight: '56px',
                                            fontSize: '14px',
                                            padding: '0 12px',
                                        }}
                                    >
                                        Take
                                    </Button>
                                    <Button
                                        size="lg"
                                        variant="outline"
                                        color="dark.6"
                                        onClick={openFilePicker}
                                        leftSection={<MdPhotoLibrary size={18} />}
                                        ff="Inter"
                                        fw={600}
                                        style={{
                                            minHeight: '56px',
                                            fontSize: '14px',
                                            padding: '0 12px',
                                        }}
                                    >
                                        Gallery
                                    </Button>
                                </Group>
                                <Text size="xs" c="dimmed" ta="center" ff="Inter">
                                    Use these buttons to directly access your phone's camera or photo gallery
                                </Text>
                            </Stack>
                        </Paper>
                    )}

                    {/* Divider for mobile */}
                    {isMobile && <Divider label="Or use live camera preview" labelPosition="center" />}

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
                                    {cameraState.hasMultipleCameras ? (
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
                                    ) : (
                                        <Box w={48} /> // Spacer for alignment
                                    )}

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
                            onClick={openFilePicker}
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
                        {isMobile
                            ? 'Use the buttons above for quick camera access, or the live preview for more control'
                            : 'You can also upload an existing photo from your device'}
                    </Text>
                </Stack>
            </Modal>

            {/* Hidden file input for gallery */}
            <input
                ref={fileInputRef}
                type="file"
                accept="image/jpeg,image/png,image/webp,image/heic"
                style={{ display: 'none' }}
                onChange={handleFileUpload}
            />

            {/* Hidden file input for direct camera capture (mobile) */}
            <input
                ref={cameraInputRef}
                type="file"
                accept="image/jpeg,image/png,image/webp,image/heic"
                capture="environment"
                style={{ display: 'none' }}
                onChange={handleDirectCapture}
            />

            {/* Hidden canvas for image capture */}
            <canvas ref={canvasRef} style={{ display: 'none' }} />
        </>
    );
};

export default PartCamera;
