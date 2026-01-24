import { useState } from 'react';
import type { Hotspot } from '../../types/parts';

interface PartsOverlayProps {
    currentAngle: string;
    hotspots: Hotspot[];
    imageWidth: number;
    imageHeight: number;
    onHotspotClick: (hotspot: Hotspot) => void;
}

// Calculate label position - offset from hotspot to avoid overlap
function getLabelPosition(hotspot: Hotspot, imageWidth: number, imageHeight: number) {
    const { x, y } = hotspot.coordinates;

    // Determine which quadrant the hotspot is in and position label accordingly
    const isLeft = x < imageWidth / 2;
    const isTop = y < imageHeight / 2;

    // Base offset distance
    const offsetX = isLeft ? -100 : 100;
    const offsetY = isTop ? -50 : 50;

    // Adjust for edge cases
    let labelX = x + offsetX;
    let labelY = y + offsetY;

    // Keep labels within bounds
    labelX = Math.max(70, Math.min(labelX, imageWidth - 70));
    labelY = Math.max(30, Math.min(labelY, imageHeight - 30));

    return { labelX, labelY };
}

export function PartsOverlay({
    currentAngle,
    hotspots,
    imageWidth,
    imageHeight,
    onHotspotClick
}: PartsOverlayProps) {
    const [activeHotspot, setActiveHotspot] = useState<string | null>(null);
    const [showAllLabels, setShowAllLabels] = useState(true);

    // Filter hotspots for current angle
    const visibleHotspots = hotspots.filter(h => h.angle === currentAngle);

    return (
        <>
            {/* Toggle button */}
            <button
                onClick={() => setShowAllLabels(!showAllLabels)}
                style={{
                    position: 'absolute',
                    top: 12,
                    right: 12,
                    background: showAllLabels ? '#0ea5e9' : 'rgba(255,255,255,0.95)',
                    color: showAllLabels ? '#ffffff' : '#0a0a0a',
                    border: '2px solid #0ea5e9',
                    borderRadius: 8,
                    padding: '8px 14px',
                    fontSize: 13,
                    fontWeight: 600,
                    fontFamily: 'Inter, sans-serif',
                    cursor: 'pointer',
                    zIndex: 20,
                    display: 'flex',
                    alignItems: 'center',
                    gap: 6,
                    boxShadow: '0 2px 8px rgba(0,0,0,0.15)',
                    transition: 'all 0.2s ease',
                }}
            >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <circle cx="12" cy="12" r="10" />
                    <path d="M12 16v-4M12 8h.01" />
                </svg>
                {showAllLabels ? 'Hide Labels' : 'Show Labels'}
            </button>

            <svg
                width="100%"
                height="100%"
                viewBox={`0 0 ${imageWidth} ${imageHeight}`}
                style={{
                    position: 'absolute',
                    top: 0,
                    left: 0,
                    pointerEvents: 'none',
                }}
            >
                <defs>
                    {/* Drop shadow filter for labels */}
                    <filter id="labelShadow" x="-20%" y="-20%" width="140%" height="140%">
                        <feDropShadow dx="0" dy="2" stdDeviation="3" floodOpacity="0.2" />
                    </filter>
                </defs>

                {visibleHotspots.map(hotspot => {
                    const { labelX, labelY } = getLabelPosition(hotspot, imageWidth, imageHeight);
                    const isActive = activeHotspot === hotspot.id;
                    const showLabel = showAllLabels || isActive;

                    // Calculate text width for background sizing
                    const textWidth = hotspot.partName.length * 7.5 + 20;

                    return (
                        <g key={hotspot.id}>
                            {/* Connecting line from part to label */}
                            {showLabel && (
                                <line
                                    x1={hotspot.coordinates.x}
                                    y1={hotspot.coordinates.y}
                                    x2={labelX}
                                    y2={labelY}
                                    stroke="#ef4444"
                                    strokeWidth={isActive ? 2.5 : 1.5}
                                    strokeLinecap="round"
                                    style={{
                                        opacity: isActive ? 1 : 0.85,
                                        transition: 'all 0.2s ease',
                                    }}
                                />
                            )}

                            {/* Red dot at the part location */}
                            <circle
                                cx={hotspot.coordinates.x}
                                cy={hotspot.coordinates.y}
                                r={isActive ? 10 : 7}
                                fill="#ef4444"
                                stroke="#ffffff"
                                strokeWidth="2.5"
                                style={{
                                    pointerEvents: 'all',
                                    cursor: 'pointer',
                                    filter: isActive ? 'drop-shadow(0 0 8px rgba(239, 68, 68, 0.7))' : 'none',
                                    transition: 'all 0.2s ease',
                                }}
                                onClick={() => onHotspotClick(hotspot)}
                                onMouseEnter={() => setActiveHotspot(hotspot.id)}
                                onMouseLeave={() => setActiveHotspot(null)}
                                onTouchStart={() => setActiveHotspot(hotspot.id)}
                            />

                            {/* Pulse ring animation on dot */}
                            <circle
                                cx={hotspot.coordinates.x}
                                cy={hotspot.coordinates.y}
                                r={12}
                                fill="none"
                                stroke="#ef4444"
                                strokeWidth="2"
                                style={{
                                    pointerEvents: 'none',
                                    opacity: 0.5,
                                }}
                                className="pulse-ring"
                            />

                            {/* Label with background */}
                            {showLabel && (
                                <g
                                    style={{
                                        pointerEvents: 'all',
                                        cursor: 'pointer',
                                    }}
                                    onClick={() => onHotspotClick(hotspot)}
                                    onMouseEnter={() => setActiveHotspot(hotspot.id)}
                                    onMouseLeave={() => setActiveHotspot(null)}
                                >
                                    {/* Label background */}
                                    <rect
                                        x={labelX - textWidth / 2}
                                        y={labelY - 13}
                                        width={textWidth}
                                        height={26}
                                        rx="5"
                                        fill={isActive ? '#0ea5e9' : 'rgba(255,255,255,0.97)'}
                                        stroke={isActive ? '#0284c7' : '#d4d4d8'}
                                        strokeWidth="1.5"
                                        filter="url(#labelShadow)"
                                        style={{
                                            transition: 'all 0.2s ease',
                                        }}
                                    />

                                    {/* Label text */}
                                    <text
                                        x={labelX}
                                        y={labelY + 4}
                                        textAnchor="middle"
                                        fill={isActive ? '#ffffff' : '#0a0a0a'}
                                        fontSize="12"
                                        fontWeight="600"
                                        fontFamily="Inter, sans-serif"
                                        style={{
                                            pointerEvents: 'none',
                                            transition: 'fill 0.2s ease',
                                        }}
                                    >
                                        {hotspot.partName}
                                    </text>
                                </g>
                            )}
                        </g>
                    );
                })}
            </svg>

            {/* Info panel showing part count */}
            <div
                style={{
                    position: 'absolute',
                    bottom: 12,
                    left: 12,
                    background: 'rgba(10, 10, 10, 0.9)',
                    backdropFilter: 'blur(8px)',
                    color: '#ffffff',
                    padding: '8px 14px',
                    borderRadius: 8,
                    fontSize: 12,
                    fontFamily: 'Inter, sans-serif',
                    fontWeight: 500,
                    display: 'flex',
                    alignItems: 'center',
                    gap: 6,
                    zIndex: 20,
                }}
            >
                <span style={{ color: '#ef4444', fontWeight: 700 }}>{visibleHotspots.length}</span>
                <span style={{ color: '#a1a1aa' }}>parts visible</span>
                <span style={{ color: '#52525b' }}>•</span>
                <span style={{ color: '#0ea5e9' }}>Tap for details</span>
            </div>

            {/* CSS Animations */}
            <style>{`
        @keyframes pulse-ring {
          0% {
            r: 8;
            opacity: 0.6;
          }
          100% {
            r: 22;
            opacity: 0;
          }
        }

        .pulse-ring {
          animation: pulse-ring 2s ease-out infinite;
        }

        /* Stagger animations for different hotspots */
        g:nth-child(odd) .pulse-ring {
          animation-delay: 0.5s;
        }
        
        g:nth-child(3n) .pulse-ring {
          animation-delay: 1s;
        }

        /* Mobile optimizations */
        @media (hover: none) and (pointer: coarse) {
          /* Larger tap targets on mobile */
          circle[style*="cursor: pointer"] {
            r: 12px;
          }
        }
      `}</style>
        </>
    );
}
