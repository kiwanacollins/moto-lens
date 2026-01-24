import { useState, useEffect, useRef, useCallback } from 'react';
import { Box, Paper, Text, Center, Group, Alert } from '@mantine/core';
import { MdRotateLeft, MdRotateRight, MdTouchApp } from 'react-icons/md';
import { FiRotateCw } from 'react-icons/fi';
import type { VehicleImage } from '../../types/vehicle';

interface Custom360ViewerProps {
    images: VehicleImage[];
    loading?: boolean;
    vehicleName?: string;
    className?: string;
    height?: number;
    dragSensitivity?: 'low' | 'medium' | 'high';
    enableAutoplay?: boolean;
    autoplaySpeed?: number;
}

const Custom360Viewer: React.FC<Custom360ViewerProps> = ({
    images = [],
    loading = false,
    vehicleName = '',
    className = '',
    height = 400,
    dragSensitivity = 'medium',
    enableAutoplay = false,
    autoplaySpeed = 2000,
}) => {
    const [currentIndex, setCurrentIndex] = useState(0);
    const [isDragging, setIsDragging] = useState(false);
    const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
    const [imagesLoaded, setImagesLoaded] = useState(false);
    const [showHint, setShowHint] = useState(true);
    const containerRef = useRef<HTMLDivElement>(null);
    const autoplayRef = useRef<ReturnType<typeof setInterval> | null>(null);

    // Filter successful images
    const validImages = images.filter(img => img.success && img.imageUrl);

    // Sensitivity settings
    const getSensitivity = () => {
        switch (dragSensitivity) {
            case 'low': return 40;    // More drag needed
            case 'high': return 10;   // Less drag needed  
            default: return 20;       // Medium
        }
    };

    const sensitivity = getSensitivity();

    // Hide hint after 3 seconds
    useEffect(() => {
        const timer = setTimeout(() => setShowHint(false), 3000);
        return () => clearTimeout(timer);
    }, []);

    // Preload images
    useEffect(() => {
        if (validImages.length === 0) return;

        let loadedCount = 0;
        let errorCount = 0;

        const checkComplete = () => {
            if (loadedCount + errorCount === validImages.length) {
                setImagesLoaded(true);
            }
        };

        validImages.forEach(img => {
            const image = new Image();
            image.onload = () => {
                loadedCount++;
                checkComplete();
            };
            image.onerror = () => {
                errorCount++;
                checkComplete();
            };
            image.src = img.imageUrl;
        });
    }, [validImages]);

    // Autoplay functionality
    useEffect(() => {
        if (enableAutoplay && imagesLoaded && validImages.length > 1) {
            autoplayRef.current = setInterval(() => {
                setCurrentIndex(prev => (prev + 1) % validImages.length);
            }, autoplaySpeed);
        }

        return () => {
            if (autoplayRef.current) {
                clearInterval(autoplayRef.current);
            }
        };
    }, [enableAutoplay, autoplaySpeed, imagesLoaded, validImages.length]);

    // Drag handlers
    const handleStart = useCallback((clientX: number, clientY: number) => {
        setIsDragging(true);
        setDragStart({ x: clientX, y: clientY });

        // Stop autoplay when user interacts
        if (autoplayRef.current) {
            clearInterval(autoplayRef.current);
            autoplayRef.current = null;
        }
    }, []);

    const handleMove = useCallback((clientX: number, _clientY: number) => {
        if (!isDragging || validImages.length <= 1) return;

        const deltaX = clientX - dragStart.x;
        const steps = Math.floor(Math.abs(deltaX) / sensitivity);

        if (steps > 0) {
            const direction = deltaX > 0 ? 1 : -1;
            const newIndex = (currentIndex + direction * steps) % validImages.length;
            const finalIndex = newIndex < 0 ? validImages.length + newIndex : newIndex;

            setCurrentIndex(finalIndex);
            setDragStart({ x: clientX, y: dragStart.y });
        }
    }, [isDragging, dragStart, currentIndex, validImages.length, sensitivity]);

    const handleEnd = useCallback(() => {
        setIsDragging(false);
    }, []);

    // Mouse events
    const handleMouseDown = (e: React.MouseEvent) => {
        e.preventDefault();
        handleStart(e.clientX, e.clientY);
    };

    const handleMouseMove = (e: React.MouseEvent) => {
        handleMove(e.clientX, e.clientY);
    };

    // Touch events
    const handleTouchStart = (e: React.TouchEvent) => {
        e.preventDefault();
        const touch = e.touches[0];
        handleStart(touch.clientX, touch.clientY);
    };

    const handleTouchMove = (e: React.TouchEvent) => {
        e.preventDefault();
        const touch = e.touches[0];
        handleMove(touch.clientX, touch.clientY);
    };

    // Navigation functions
    const goToNext = () => {
        if (validImages.length <= 1) return;
        setCurrentIndex(prev => (prev + 1) % validImages.length);
    };

    const goToPrev = () => {
        if (validImages.length <= 1) return;
        setCurrentIndex(prev => (prev - 1 + validImages.length) % validImages.length);
    };

    // Loading state
    if (loading || !imagesLoaded) {
        return (
            <Paper
                shadow="sm"
                p="xl"
                radius="lg"
                withBorder
                h={height}
                className={className}
                style={{ borderColor: '#e4e4e7', backgroundColor: '#ffffff' }}
            >
                <Center h="100%">
                    <div style={{ textAlign: 'center' }}>
                        <Box mb="lg" style={{
                            width: '60px',
                            height: '60px',
                            margin: '0 auto 16px',
                            borderRadius: '50%',
                            background: 'conic-gradient(from 0deg, #0ea5e9, #0ea5e9 25%, #e4e4e7 25%, #e4e4e7 50%, #0ea5e9 50%, #0ea5e9 75%, #e4e4e7 75%)',
                            animation: 'spin 1s linear infinite',
                        }} />
                        <Text c="dark.9" fw={600} size="lg" ff="Inter">
                            {loading ? 'Loading Vehicle Images...' : 'Preparing 360° View...'}
                        </Text>
                        <Text c="dark.6" size="sm" ff="Inter" mt="xs">
                            {vehicleName}
                        </Text>
                    </div>
                </Center>

                <style>{`
          @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
          }
        `}</style>
            </Paper>
        );
    }

    // Error state
    if (validImages.length === 0) {
        return (
            <Paper
                shadow="sm"
                p="xl"
                radius="lg"
                withBorder
                h={height}
                className={className}
                style={{ borderColor: '#e4e4e7', backgroundColor: '#ffffff' }}
            >
                <Center h="100%">
                    <Alert color="red" title="No Images Available">
                        <Text size="sm">
                            Unable to load vehicle images. Please try again or check your connection.
                        </Text>
                    </Alert>
                </Center>
            </Paper>
        );
    }

    const currentImage = validImages[currentIndex];

    return (
        <Paper
            shadow="sm"
            p={0}
            radius="lg"
            withBorder
            h={height}
            className={className}
            style={{
                borderColor: '#e4e4e7',
                backgroundColor: '#ffffff',
                overflow: 'hidden',
                position: 'relative'
            }}
        >
            {/* Main image container */}
            <Box
                ref={containerRef}
                h="100%"
                w="100%"
                onMouseDown={handleMouseDown}
                onMouseMove={handleMouseMove}
                onMouseUp={handleEnd}
                onMouseLeave={handleEnd}
                onTouchStart={handleTouchStart}
                onTouchMove={handleTouchMove}
                onTouchEnd={handleEnd}
                style={{
                    cursor: isDragging ? 'grabbing' : 'grab',
                    userSelect: 'none',
                    position: 'relative',
                    background: 'linear-gradient(135deg, #fafafa 0%, #f4f4f5 100%)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                }}
            >
                {/* Vehicle Image */}
                <img
                    src={currentImage.imageUrl}
                    alt={`${vehicleName} - ${currentImage.angle} view`}
                    style={{
                        maxWidth: '100%',
                        maxHeight: '100%',
                        width: 'auto',
                        height: 'auto',
                        objectFit: 'contain',
                        objectPosition: 'center',
                        transition: isDragging ? 'none' : 'opacity 0.2s ease',
                        display: 'block',
                    }}
                    draggable={false}
                />

                {/* Drag hint overlay */}
                {showHint && validImages.length > 1 && (
                    <Box
                        pos="absolute"
                        top="50%"
                        left="50%"
                        style={{
                            transform: 'translate(-50%, -50%)',
                            background: 'rgba(10, 10, 10, 0.8)',
                            backdropFilter: 'blur(8px)',
                            borderRadius: '12px',
                            padding: '12px 20px',
                            animation: 'fadeInOut 3s ease',
                        }}
                    >
                        <Group gap="xs" align="center">
                            <MdTouchApp size={20} color="#0ea5e9" />
                            <Text c="white" size="sm" ff="Inter" fw={500}>
                                Drag to rotate
                            </Text>
                            <FiRotateCw size={16} color="#0ea5e9" />
                        </Group>
                    </Box>
                )}

                {/* Image info overlay */}
                <Box
                    pos="absolute"
                    bottom="0"
                    left="0"
                    right="0"
                    p="md"
                    style={{
                        background: 'linear-gradient(transparent, rgba(10, 10, 10, 0.6))',
                        backdropFilter: 'blur(4px)',
                    }}
                >
                    <Group justify="space-between" align="center">
                        <Box>
                            <Text c="white" size="sm" ff="Inter" fw={600}>
                                {vehicleName}
                            </Text>
                            <Text c="gray.3" size="xs" ff="Inter">
                                {currentIndex + 1} of {validImages.length}
                            </Text>
                        </Box>

                        {validImages.length > 1 && (
                            <Group gap="xs">
                                <button
                                    onClick={goToPrev}
                                    style={{
                                        background: 'rgba(255, 255, 255, 0.2)',
                                        border: 'none',
                                        borderRadius: '6px',
                                        padding: '8px',
                                        cursor: 'pointer',
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                    }}
                                >
                                    <MdRotateLeft size={20} color="white" />
                                </button>
                                <button
                                    onClick={goToNext}
                                    style={{
                                        background: 'rgba(255, 255, 255, 0.2)',
                                        border: 'none',
                                        borderRadius: '6px',
                                        padding: '8px',
                                        cursor: 'pointer',
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                    }}
                                >
                                    <MdRotateRight size={20} color="white" />
                                </button>
                            </Group>
                        )}
                    </Group>
                </Box>

                {/* Image quality indicator */}
                {currentImage.source && (
                    <Box
                        pos="absolute"
                        top="md"
                        right="md"
                        px="xs"
                        py={4}
                        style={{
                            background: 'rgba(10, 10, 10, 0.6)',
                            borderRadius: '6px',
                            fontSize: '10px',
                            color: '#0ea5e9',
                            fontFamily: 'JetBrains Mono',
                            fontWeight: 500,
                        }}
                    >
                        {currentImage.searchEngine || 'web'}
                    </Box>
                )}
            </Box>

            <style>{`
        @keyframes fadeInOut {
          0% { opacity: 0; transform: translate(-50%, -50%) scale(0.8); }
          20% { opacity: 1; transform: translate(-50%, -50%) scale(1); }
          80% { opacity: 1; transform: translate(-50%, -50%) scale(1); }
          100% { opacity: 0; transform: translate(-50%, -50%) scale(0.8); }
        }
      `}</style>
        </Paper>
    );
};

export default Custom360Viewer;