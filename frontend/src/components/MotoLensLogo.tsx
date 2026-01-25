/**
 * MotoLensLogo - Backwards Compatibility Export
 * Re-exports GermanCarMedicLogo as MotoLensLogo for existing imports
 */
import { GermanCarMedicLogo } from './GermanCarMedicLogo';

interface MotoLensLogoProps {
  size?: number;
  showCorners?: boolean;
}

/**
 * @deprecated Use GermanCarMedicLogo instead
 */
export const MotoLensLogo: React.FC<MotoLensLogoProps> = ({ size = 120 }) => {
  return <GermanCarMedicLogo size={size} />;
};

export default MotoLensLogo;
