import React from 'react';

interface MotoLensLogoProps {
  size?: number;
  showCorners?: boolean;
}

export const MotoLensLogo: React.FC<MotoLensLogoProps> = ({ size = 120, showCorners = true }) => {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 400 400"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      {/* Lens Circle - Electric Blue */}
      <circle cx="200" cy="200" r="110" stroke="#00D9FF" strokeWidth="10" fill="none" />
      <circle cx="200" cy="200" r="86" stroke="#00D9FF" strokeWidth="6" fill="none" opacity="0.5" />

      {/* Lens Highlight */}
      <circle cx="176" cy="176" r="24" fill="#00D9FF" opacity="0.3" />

      {/* Crosshair/Focus Indicator */}
      <line
        x1="200"
        y1="75"
        x2="200"
        y2="106"
        stroke="#00D9FF"
        strokeWidth="5"
        strokeLinecap="round"
      />
      <line
        x1="200"
        y1="294"
        x2="200"
        y2="325"
        stroke="#00D9FF"
        strokeWidth="5"
        strokeLinecap="round"
      />
      <line
        x1="75"
        y1="200"
        x2="106"
        y2="200"
        stroke="#00D9FF"
        strokeWidth="5"
        strokeLinecap="round"
      />
      <line
        x1="294"
        y1="200"
        x2="325"
        y2="200"
        stroke="#00D9FF"
        strokeWidth="5"
        strokeLinecap="round"
      />

      {/* Gear/Mechanical Element - Gunmetal Gray */}
      <g transform="translate(200, 200)">
        <circle r="35" fill="#2C3539" />
        {/* Gear Teeth */}
        <path d="M 0,-35 L 8,-43 L -8,-43 Z" fill="#2C3539" />
        <path d="M 35,0 L 43,8 L 43,-8 Z" fill="#2C3539" />
        <path d="M 0,35 L 8,43 L -8,43 Z" fill="#2C3539" />
        <path d="M -35,0 L -43,8 L -43,-8 Z" fill="#2C3539" />

        {/* Inner Circle */}
        <circle r="20" fill="#0A0A0A" />
        <circle r="12" stroke="#00D9FF" strokeWidth="2" fill="none" />
      </g>

      {/* Corner Accent Lines */}
      {showCorners && (
        <>
          <line
            x1="94"
            y1="94"
            x2="125"
            y2="94"
            stroke="#00D9FF"
            strokeWidth="3"
            strokeLinecap="round"
            opacity="0.7"
          />
          <line
            x1="94"
            y1="94"
            x2="94"
            y2="125"
            stroke="#00D9FF"
            strokeWidth="3"
            strokeLinecap="round"
            opacity="0.7"
          />

          <line
            x1="306"
            y1="94"
            x2="275"
            y2="94"
            stroke="#00D9FF"
            strokeWidth="3"
            strokeLinecap="round"
            opacity="0.7"
          />
          <line
            x1="306"
            y1="94"
            x2="306"
            y2="125"
            stroke="#00D9FF"
            strokeWidth="3"
            strokeLinecap="round"
            opacity="0.7"
          />

          <line
            x1="94"
            y1="306"
            x2="125"
            y2="306"
            stroke="#00D9FF"
            strokeWidth="3"
            strokeLinecap="round"
            opacity="0.7"
          />
          <line
            x1="94"
            y1="306"
            x2="94"
            y2="275"
            stroke="#00D9FF"
            strokeWidth="3"
            strokeLinecap="round"
            opacity="0.7"
          />

          <line
            x1="306"
            y1="306"
            x2="275"
            y2="306"
            stroke="#00D9FF"
            strokeWidth="3"
            strokeLinecap="round"
            opacity="0.7"
          />
          <line
            x1="306"
            y1="306"
            x2="306"
            y2="275"
            stroke="#00D9FF"
            strokeWidth="3"
            strokeLinecap="round"
            opacity="0.7"
          />
        </>
      )}
    </svg>
  );
};
