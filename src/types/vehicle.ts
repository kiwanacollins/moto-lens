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
  // Enrichment metadata
  _enriched?: boolean;
  _enrichedAt?: string;
  _enrichedFields?: string[];
  _enrichmentError?: string;
}

export interface VehicleImage {
  angle: string;
  url: string;
}

export interface VehicleSummary {
  bulletPoints: string[];
}
