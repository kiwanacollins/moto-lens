import React, { useState, useEffect } from 'react';
import { Box, Paper, Loader, Text, Center, Group } from '@mantine/core';
import { MdRotateLeft, MdRotateRight, MdTouchApp } from 'react-icons/md';
import { FiRotateCw } from 'react-icons/fi';

// Import react-360-view
import React360Viewer from 'react-360-view';

// Import styles for mobile optimization
import './Vehicle360Viewer.css';

// Import vehicle service
import { getVehicleImages } from '../../services/vehicleService';

interface Vehicle360ViewerProps {
    images: string[];
    loading?: boolean;
    vehicleName?: string;
    className?: string;
    height?: number;
    // Sensitivity configuration props
    dragSensitivity?: 'low' | 'medium' | 'high';
    enableAutoplay?: boolean;
    autoplaySpeed?: number;
    // Vehicle data for loading images
    vehicleData?: any;
    onImagesLoaded?: (images: string[]) => void;
}

export default function Vehicle360Viewer({
    images = [],
    loading = false,
    vehicleName = '',
    className = '',
    height = 400,
    dragSensitivity = 'medium',
    enableAutoplay = false,
    autoplaySpeed = 2000,
    vehicleData = null,
    onImagesLoaded = () => { }
}: Vehicle360ViewerProps) {
    const [imagesLoaded, setImagesLoaded] = useState(false);
    const [imageErrors, setImageErrors] = useState<number>(0);
    const [showHint, setShowHint] = useState(true);
    const [backendImages, setBackendImages] = useState<string[]>([]);
    const [loadingImages, setLoadingImages] = useState(false);    // Sample images for testing (placeholder car images)
    const sampleImages = [
        '/api/placeholder/400/300', // Front
        '/api/placeholder/400/300', // Front-right
        '/api/placeholder/400/300', // Right
        '/api/placeholder/400/300', // Rear-right
        '/api/placeholder/400/300', // Rear
        '/api/placeholder/400/300', // Rear-left
        '/api/placeholder/400/300', // Left
        '/api/placeholder/400/300', // Front-left
    ];

    // Use sample images if no real images provided
    const viewerImages = backendImages.length > 0 ? backendImages : (images.length > 0 ? images : sampleImages);

    // Calculate drag sensitivity settings
    const getSensitivitySettings = () => {
        switch (dragSensitivity) {
            case 'low':
                return {
                    dragTolerance: 15,
                    velocity: 0.05,
                    swipeThreshold: 20
                };
            case 'high':
                return {
                    dragTolerance: 3,
                    velocity: 0.2,
                    swipeThreshold: 5
                };
            default: // medium
                return {
                    dragTolerance: 8,
                    velocity: 0.1,
                    swipeThreshold: 10
                };
        }
    };

    const sensitivitySettings = getSensitivitySettings(); useEffect(() => {
        // Hide hint after 3 seconds
        const timer = setTimeout(() => {
            setShowHint(false);
        }, 3000);

        return () => clearTimeout(timer);
    }, []);

    useEffect(() => {
        if (viewerImages.length === 0) return;

        let loadedCount = 0;
        let errorCount = 0;

        const checkImageLoading = () => {
            if (loadedCount + errorCount === viewerImages.length) {
                setImagesLoaded(true);
                setImageErrors(errorCount);
            }
        };

        viewerImages.forEach((src) => {
            const img = new Image();
            img.onload = () => {
                loadedCount++;
                checkImageLoading();
            };
            img.onerror = () => {
                errorCount++;
                checkImageLoading();
            };
            img.src = src;
        });
    }, [viewerImages]);

    // Effect to load images from backend when vehicleData is provided
    useEffect(() => {
        if (!vehicleData || backendImages.length > 0) return;

        async function loadBackendImages() {
            try {
                setLoadingImages(true);
                const vehicleImages = await getVehicleImages(vehicleData);
                const imageUrls = vehicleImages.map(img => img.url);
                setBackendImages(imageUrls);
                onImagesLoaded(imageUrls);
            } catch (error) {
                console.error('Failed to load vehicle images:', error);
                // Fallback to sample images on error
                setBackendImages([]);
            } finally {
                setLoadingImages(false);
            }
        }

        loadBackendImages();
    }, [vehicleData, onImagesLoaded, backendImages.length]);

    if (loading || loadingImages) {
        return (
            <Paper
                shadow="sm"
                p="xl"
                radius="lg"
                withBorder
                bg="white"
                style={{
                    height,
                    borderColor: '#e4e4e7',
                }}
                className={className}
            >
                <Center h="100%">
                    <div style={{ textAlign: 'center' }}>
                        <Loader size="lg" color="blue.4" mb="md" />
                        <Text size="lg" c="dark.9" ff="Inter" fw={500} mb="xs">
                            Generating 360° View
                        </Text>
                        <Text size="sm" c="dark.6" ff="Inter">
                            Creating vehicle images...
                        </Text>
                    </div>
                </Center>
            </Paper>
        );
    }

    if (!imagesLoaded && !loading) {
        return (
            <Paper
                shadow="sm"
                radius="lg"
                withBorder
                bg="white"
                style={{
                    borderColor: '#e4e4e7',
                    overflow: 'hidden',
                }}
                className={className}
            >
                {/* Loading skeleton header */}
                <Box p="lg" style={{ borderBottom: '1px solid #e4e4e7' }}>
                    <Group justify="space-between" align="center">
                        <div style={{ flex: 1 }}>
                            <Box
                                h={24}
                                bg="#f4f4f5"
                                style={{ borderRadius: '4px', width: '60%' }}
                                mb="sm"
                            />
                            <Box
                                h={16}
                                bg="#f4f4f5"
                                style={{ borderRadius: '4px', width: '40%' }}
                            />
                        </div>
                        <Box
                            w={60}
                            h={24}
                            bg="#f4f4f5"
                            style={{ borderRadius: '4px' }}
                        />
                    </Group>
                </Box>

                {/* Loading skeleton content */}
                <Box
                    style={{
                        height: height - 100,
                        background: 'linear-gradient(90deg, #fafafa 25%, #f4f4f5 50%, #fafafa 75%)',
                        backgroundSize: '200% 100%',
                        animation: 'loading-shimmer 1.5s infinite',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center'
                    }}
                >
                    <div style={{ textAlign: 'center' }}>
                        <Loader size="lg" color="blue.4" mb="md" />
                        <Text size="lg" c="dark.9" ff="Inter" fw={500} mb="xs">
                            Loading 360° View
                        </Text>
                        <Text size="sm" c="dark.6" ff="Inter">
                            Preparing vehicle images...
                        </Text>
                    </div>
                </Box>
            </Paper>
        );
    } return (
        <Paper
            shadow="sm"
            radius="lg"
            withBorder
            bg="white"
            style={{
                borderColor: '#e4e4e7',
                overflow: 'hidden',
                position: 'relative'
            }}
            className={className}
        >
            {/* Header */}
            <Box p="lg" style={{ borderBottom: '1px solid #e4e4e7' }}>
                <Group justify="space-between" align="center">
                    <div>
                        <Text
                            ff="Inter"
                            fw={600}
                            c="dark.9"
                            size="lg"
                            mb={2}
                        >
                            360° Vehicle View
                        </Text>
                        {vehicleName && (
                            <Text
                                size="sm"
                                c="dark.6"
                                ff="Inter"
                                fw={400}
                            >
                                {vehicleName}
                            </Text>
                        )}
                    </div>

                    <Group gap="xs" align="center">
                        <Box
                            p="xs"
                            style={{
                                backgroundColor: '#f4f4f5',
                                borderRadius: '8px',
                            }}
                        >
                            <FiRotateCw size={16} color="#0ea5e9" />
                        </Box>
                        <Text
                            size="xs"
                            c="blue.5"
                            ff="Inter"
                            fw={500}
                            tt="uppercase"
                            lts={0.5}
                        >
                            Interactive
                        </Text>
                    </Group>
                </Group>

                {/* Sensitivity indicator */}
                <Group gap="xs" mt="sm" align="center">
                    <Text size="xs" c="dimmed" ff="Inter">
                        Sensitivity:
                    </Text>
                    <Text size="xs" c="blue.4" ff="Inter" fw={500} tt="capitalize">
                        {dragSensitivity}
                    </Text>
                </Group>
            </Box>

            {/* 360 Viewer */}
            <Box style={{ position: 'relative' }}>
                <React360Viewer
                    images={viewerImages}
                    width="100%"
                    height={height - 100} // Subtract header height
                    className="react-360-viewer"
                    spinReverse={false}
                    autoplay={enableAutoplay}
                    autoplaySpeed={autoplaySpeed}
                    loops={1}
                    frameRate={60}
                    // Dynamic sensitivity settings
                    dragTolerance={sensitivitySettings.dragTolerance}
                    mouseDrag={true}
                    touchDrag={true}
                    keys={true}
                    boxShadow="none"
                    // Enhanced touch handling
                    swipeThreshold={sensitivitySettings.swipeThreshold}
                    velocity={sensitivitySettings.velocity}
                    style={{
                        borderRadius: '0 0 12px 12px',
                        backgroundColor: '#fafafa',
                        cursor: 'grab'
                    }}
                />                {/* Swipe Hint Overlay */}
                {showHint && (
                    <Box
                        style={{
                            position: 'absolute',
                            top: '50%',
                            left: '50%',
                            transform: 'translate(-50%, -50%)',
                            backgroundColor: 'rgba(0, 0, 0, 0.7)',
                            color: 'white',
                            padding: '12px 20px',
                            borderRadius: '8px',
                            pointerEvents: 'none',
                            zIndex: 10,
                            textAlign: 'center'
                        }}
                    >
                        <Group gap="xs" justify="center" align="center" mb="xs">
                            <MdTouchApp size={20} />
                            <Text size="sm" ff="Inter" fw={500}>
                                Drag to rotate
                            </Text>
                        </Group>
                        <Group gap="md" justify="center">
                            <Group gap={4} align="center">
                                <MdRotateLeft size={16} />
                                <Text size="xs" ff="Inter" opacity={0.8}>
                                    Swipe left
                                </Text>
                            </Group>
                            <Group gap={4} align="center">
                                <MdRotateRight size={16} />
                                <Text size="xs" ff="Inter" opacity={0.8}>
                                    Swipe right
                                </Text>
                            </Group>
                        </Group>
                    </Box>
                )}

                {/* Error indicator */}
                {imageErrors > 0 && (
                    <Box
                        style={{
                            position: 'absolute',
                            bottom: 10,
                            right: 10,
                            backgroundColor: 'rgba(239, 68, 68, 0.9)',
                            color: 'white',
                            padding: '6px 12px',
                            borderRadius: '6px',
                            fontSize: '12px',
                            zIndex: 10
                        }}
                    >
                        <Text size="xs" ff="Inter">
                            {imageErrors} image{imageErrors !== 1 ? 's' : ''} failed to load
                        </Text>
                    </Box>
                )}
            </Box>
        </Paper>
    );
}