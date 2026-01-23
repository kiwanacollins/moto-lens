// Parts-related type definitions

export interface PartInfo {
  id: string;
  name: string;
  description: string;
  partNumber?: string;
  symptoms?: string[];
  spareParts?: SparePart[];
}

export interface SparePart {
  name: string;
  partNumber: string;
  description: string;
  price?: number;
}

export interface Hotspot {
  id: string;
  partName: string;
  angle: string;
  coordinates: { x: number; y: number };
  radius: number;
}
