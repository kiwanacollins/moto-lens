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
}

export interface VehicleImage {
  angle: string;
  url: string;
}

export interface VehicleSummary {
  bulletPoints: string[];
}
