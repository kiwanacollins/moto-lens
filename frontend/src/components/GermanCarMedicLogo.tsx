import React from 'react';

interface GermanCarMedicLogoProps {
  size?: number;
}

/**
 * German Car Medic Logo Component
 * Uses the car.svg from public folder
 */
export const GermanCarMedicLogo: React.FC<GermanCarMedicLogoProps> = ({ 
  size = 120
}) => {
  // Calculate dimensions based on original aspect ratio (600x338)
  const aspectRatio = 600 / 338;
  const width = size * aspectRatio;
  const height = size;

  return (
    <img 
      src="/car.svg" 
      alt="German Car Medic"
      width={width}
      height={height}
      style={{
        objectFit: 'contain',
        display: 'block',
        margin: '0 auto',
      }}
    />
  );
};

export default GermanCarMedicLogo;
