// Vehicle-related type definitions

export interface VehicleData {
  make: string;
  model: string;
  year: number;
  trim?: string;
  engine: string;
  bodyType: string;
  manufacturer: string;
  vin: string;
  transmission?: string;
  drivetrain?: string;
  fuelType?: string;
  displacement?: string;
  cylinders?: number;
  horsepower?: string;
  torque?: string;
  doors?: number;
  seats?: number;
  origin?: string; // Country of manufacture
  vinValid?: boolean; // VIN validation status from backend
  // Enrichment metadata
  _enriched?: boolean;
  _enrichedAt?: string;
  _enrichedFields?: string[];
  _enrichmentError?: string;
}

export interface VehicleImage {
  angle: string;
  imageUrl: string;
  thumbnail?: string;
  title?: string;
  source?: string;
  searchEngine?: string;
  width?: number;
  height?: number;
  success: boolean;
  error?: string | null;
  model: string;
  isBase64: boolean;
  generatedAt?: string;
  // Legacy fields for backward compatibility
  url?: string;
}

export interface VehicleSummary {
  bulletPoints: string[];
}
