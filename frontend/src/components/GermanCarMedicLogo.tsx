import React from 'react';

interface GermanCarMedicLogoProps {
  size?: number;
  width?: number | string;
  height?: number | string;
  style?: React.CSSProperties;
}

/**
 * German Car Medic Logo Component
 * Uses the file.svg from public folder
 */
export const GermanCarMedicLogo: React.FC<GermanCarMedicLogoProps> = ({
  size = 120,
  width,
  height,
  style,
}) => {
  const resolvedWidth = width ?? size;
  const resolvedHeight = height;

  return (
    <img
      src="/file.svg"
      alt="German Car Medic"
      width={resolvedWidth}
      height={resolvedHeight}
      style={{
        objectFit: 'contain',
        display: 'block',
        margin: '0 auto',
        width: resolvedWidth,
        height: resolvedHeight ?? 'auto',
        ...style,
      }}
    />
  );
};

export default GermanCarMedicLogo;
