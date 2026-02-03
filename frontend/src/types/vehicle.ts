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
  displacement?: number; // In liters
  cylinders?: number;
  horsepower?: number; // HP
  kilowatts?: number; // kW
  torque?: string;
  doors?: number;
  seats?: number;
  origin?: string; // Country of manufacture
  vinValid?: boolean; // VIN validation status from backend

  // Extended vehicle data from Zyla Labs
  engineType?: string; // V6, V8, Inline-4, etc.
  engineHead?: string; // SOHC, DOHC, etc.
  engineValves?: number;
  emissionStandard?: string; // Euro 4, etc.
  vehicleType?: string; // Passenger car, etc.
  style?: string; // Body style details
  manufacturerAddress?: string; // Full manufacturer address
  region?: string; // Europe, etc.
  note?: string; // Additional notes from API

  // Enrichment metadata
  _enriched?: boolean;
  _enrichedAt?: string;
  _enrichedFields?: string[];
  _enrichmentError?: string;
  _source?: string; // Which API provided the data
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
