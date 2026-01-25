import { useState, useEffect, useRef, useCallback } from 'react';
import { Box, Paper, Text, Center, Group, Alert } from '@mantine/core';
import { MdRotateLeft, MdRotateRight, MdTouchApp } from 'react-icons/md';
import { FiRotateCw } from 'react-icons/fi';
import type { VehicleImage } from '../../types/vehicle';
import type { Hotspot, PartInfo } from '../../types/parts';
import { PartsOverlay } from '../parts/PartsOverlay';
import { PartDetailModal } from '../parts/PartDetailModal';
import { identifyPart } from '../../services/partsService';
import hotspotsData from '../../data/hotspots.json';

interface Custom360ViewerProps {
    images: VehicleImage[];
    loading?: boolean;
    vehicleName?: string;
    vehicleInfo?: object; // Vehicle data for API calls
    className?: string;
    height?: number;
    dragSensitivity?: 'low' | 'medium' | 'high';
    enableAutoplay?: boolean;
    autoplaySpeed?: number;
    enableHotspots?: boolean;
    onPartClick?: (partName: string) => void;
}

const Custom360Viewer: React.FC<Custom360ViewerProps> = ({
    images = [],
    loading = false,
    vehicleName = '',
    vehicleInfo = {},
    className = '',
    height = 400,
    dragSensitivity = 'medium',
    enableAutoplay = false,
    autoplaySpeed = 2000,
    enableHotspots = true,
    onPartClick,
}) => {
    const [currentIndex, setCurrentIndex] = useState(0);
    const [isDragging, setIsDragging] = useState(false);
    const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
    const [imagesLoaded, setImagesLoaded] = useState(false);
    const [showHint, setShowHint] = useState(true);
    const [showLabels, setShowLabels] = useState(true); // Persist labels visibility across angle changes

    // Modal state for part details
    const [modalOpened, setModalOpened] = useState(false);
    const [selectedPartInfo, setSelectedPartInfo] = useState<PartInfo | null>(null);
    const [selectedHotspot, setSelectedHotspot] = useState<Hotspot | null>(null);
    const [loadingPartInfo, setLoadingPartInfo] = useState(false);

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

    // Hotspot data from JSON
    const hotspots = (hotspotsData.common as Hotspot[]) || [];

    // Handle hotspot click
    const handleHotspotClick = useCallback(async (hotspot: Hotspot) => {
        console.log('Part clicked:', hotspot.partName);

        // Store selected hotspot for visual connection
        setSelectedHotspot(hotspot);

        // Open modal immediately with loading state
        setModalOpened(true);
        setLoadingPartInfo(true);

        try {
            // Fetch part information from API
            const partInfo = await identifyPart(hotspot.partName, vehicleInfo);
            setSelectedPartInfo(partInfo);
        } catch (error) {
            console.error('Failed to fetch part info:', error);
            // Show error state in modal
            setSelectedPartInfo(null);
        } finally {
            setLoadingPartInfo(false);
        }

        // Call legacy prop if provided
        if (onPartClick) {
            onPartClick(hotspot.partName);
        }
    }, [onPartClick, vehicleInfo]);

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

    // Touch events - using useEffect to add non-passive listeners
    useEffect(() => {
        const container = containerRef.current;
        if (!container) return;

        const handleTouchStart = (e: TouchEvent) => {
            // Only handle touches on the image/overlay areas, not on buttons
            const target = e.target as HTMLElement;
            if (target.tagName === 'BUTTON' || target.closest('button')) {
                return; // Don't interfere with button clicks
            }

            e.preventDefault();
            const touch = e.touches[0];
            handleStart(touch.clientX, touch.clientY);
        };

        const handleTouchMove = (e: TouchEvent) => {
            // Only handle if we're already dragging
            if (!isDragging) return;

            e.preventDefault();
            const touch = e.touches[0];
            handleMove(touch.clientX, touch.clientY);
        };

        const handleTouchEnd = () => {
            handleEnd();
        };

        // Add listeners with { passive: false } to allow preventDefault
        container.addEventListener('touchstart', handleTouchStart, { passive: false });
        container.addEventListener('touchmove', handleTouchMove, { passive: false });
        container.addEventListener('touchend', handleTouchEnd);

        return () => {
            container.removeEventListener('touchstart', handleTouchStart);
            container.removeEventListener('touchmove', handleTouchMove);
            container.removeEventListener('touchend', handleTouchEnd);
        };
    }, [handleStart, handleMove, handleEnd, isDragging]);

    // Navigation functions
    const goToNext = () => {
        console.log('goToNext clicked, validImages.length:', validImages.length);
        if (validImages.length <= 1) return;
        setCurrentIndex(prev => {
            const newIndex = (prev + 1) % validImages.length;
            console.log('Next: current index', prev, '-> new index', newIndex);
            return newIndex;
        });
    };

    const goToPrev = () => {
        console.log('goToPrev clicked, validImages.length:', validImages.length);
        if (validImages.length <= 1) return;
        setCurrentIndex(prev => {
            const newIndex = (prev - 1 + validImages.length) % validImages.length;
            console.log('Prev: current index', prev, '-> new index', newIndex);
            return newIndex;
        });
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

                {/* SVG Hotspot Overlay */}
                {enableHotspots && imagesLoaded && !isDragging && (
                    <PartsOverlay
                        currentAngle={currentImage.angle}
                        hotspots={hotspots}
                        imageWidth={800}
                        imageHeight={600}
                        onHotspotClick={handleHotspotClick}
                        showLabels={showLabels}
                        onToggleLabels={() => setShowLabels(!showLabels)}
                    />
                )}

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
                                    onClick={(e) => {
                                        e.stopPropagation(); // Prevent event bubbling
                                        goToPrev();
                                    }}
                                    style={{
                                        background: 'rgba(14, 165, 233, 0.9)', // Electric Blue
                                        border: 'none',
                                        borderRadius: '8px',
                                        padding: '10px',
                                        cursor: 'pointer',
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        minWidth: '44px',
                                        minHeight: '44px',
                                        transition: 'all 0.2s ease',
                                    }}
                                    onMouseEnter={(e) => {
                                        e.currentTarget.style.background = 'rgba(14, 165, 233, 1)';
                                        e.currentTarget.style.transform = 'scale(1.05)';
                                    }}
                                    onMouseLeave={(e) => {
                                        e.currentTarget.style.background = 'rgba(14, 165, 233, 0.9)';
                                        e.currentTarget.style.transform = 'scale(1)';
                                    }}
                                >
                                    <MdRotateLeft size={24} color="white" />
                                </button>
                                <button
                                    onClick={(e) => {
                                        e.stopPropagation(); // Prevent event bubbling
                                        goToNext();
                                    }}
                                    style={{
                                        background: 'rgba(14, 165, 233, 0.9)', // Electric Blue
                                        border: 'none',
                                        borderRadius: '8px',
                                        padding: '10px',
                                        cursor: 'pointer',
                                        display: 'flex',
                                        alignItems: 'center',
                                        justifyContent: 'center',
                                        minWidth: '44px',
                                        minHeight: '44px',
                                        transition: 'all 0.2s ease',
                                    }}
                                    onMouseEnter={(e) => {
                                        e.currentTarget.style.background = 'rgba(14, 165, 233, 1)';
                                        e.currentTarget.style.transform = 'scale(1.05)';
                                    }}
                                    onMouseLeave={(e) => {
                                        e.currentTarget.style.background = 'rgba(14, 165, 233, 0.9)';
                                        e.currentTarget.style.transform = 'scale(1)';
                                    }}
                                >
                                    <MdRotateRight size={24} color="white" />
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

            {/* Part Detail Modal */}
            <PartDetailModal
                opened={modalOpened}
                onClose={() => setModalOpened(false)}
                partInfo={selectedPartInfo}
                clickedHotspot={selectedHotspot}
                loading={loadingPartInfo}
            />
        </Paper>
    );
};

export default Custom360Viewer;