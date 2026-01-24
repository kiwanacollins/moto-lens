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

export interface AftermarketAlternative {
  brand: string;
  partNumber: string;
  qualityRating: number;
  priceRange: string;
}

export interface FailureFrequency {
  rating: 'low' | 'medium' | 'high';
  commonIssues: string[];
  avgLifespanYears: number;
  replacementFrequency: 'rare' | 'occasional' | 'common' | 'frequent';
}

export interface SupplierCatalogs {
  bmw: string;
  audi: string;
  mercedes: string;
  vw: string;
  porsche: string;
}

export interface OEMPartNumbers {
  bmw: string;
  audi: string;
  mercedes: string;
  vw: string;
  porsche: string;
}

export interface Hotspot {
  id: string;
  partName: string;
  angle: string;
  coordinates: { x: number; y: number };
  radius: number;
  // Enhanced data for spare parts workflow
  oemPartNumbers?: OEMPartNumbers;
  aftermarketAlternatives?: AftermarketAlternative[];
  failureFrequency?: FailureFrequency;
  supplierCatalogs?: SupplierCatalogs;
}
