// Vehicle service layer - API calls for vehicle-related operations
import type { VehicleData, VehicleSummary, VehicleImage } from '../types/vehicle';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3001/api';

/**
 * Decodes a VIN and returns vehicle information
 */
export async function decodeVIN(vin: string): Promise<VehicleData> {
  const response = await fetch(`${API_BASE_URL}/vin/decode`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ vin }),
  });

  if (!response.ok) {
    throw new Error('Failed to decode VIN');
  }

  const data = await response.json();

  // Backend wraps response in { success: true, vehicle: {...} }
  return data.vehicle || data;
}

/**
 * Gets web-searched vehicle images from different angles using VIN
 */
export async function getVehicleImages(vin: string): Promise<VehicleImage[]> {
  const response = await fetch(`${API_BASE_URL}/vehicle/images/${encodeURIComponent(vin)}`, {
    method: 'GET',
    headers: {
      Accept: 'application/json',
    },
  });

  if (!response.ok) {
    throw new Error('Failed to get vehicle images');
  }

  const data = await response.json();

  // Return the images array from the web search response
  return data.images || [];
}

/**
 * Gets web-searched vehicle images using vehicle data (fallback method)
 */
export async function getVehicleImagesByData(vehicleData: VehicleData): Promise<VehicleImage[]> {
  const response = await fetch(`${API_BASE_URL}/vehicle/images`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      vehicleData,
    }),
  });

  if (!response.ok) {
    throw new Error('Failed to get vehicle images');
  }

  const data = await response.json();

  // Return the images array from the web search response
  return data.images || [];
}

/**
 * Gets AI-generated vehicle summary
 */
export async function getVehicleSummary(vehicleData: VehicleData): Promise<VehicleSummary> {
  const response = await fetch(`${API_BASE_URL}/vehicle/summary/${vehicleData.vin}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    throw new Error('Failed to get vehicle summary');
  }

  const data = await response.json();

  // Transform backend response to match frontend interface
  // Backend returns { summary: [...] } not { bulletPoints: [...] }
  return {
    bulletPoints: data.summary || data.bulletPoints || [],
  };
}

/**
 * Search for spare parts images using web search
 */
export async function getPartImages(partName: string, vin: string): Promise<VehicleImage[]> {
  const response = await fetch(
    `${API_BASE_URL}/parts/images?partName=${encodeURIComponent(partName)}&vin=${encodeURIComponent(vin)}`,
    {
      method: 'GET',
      headers: {
        Accept: 'application/json',
      },
    }
  );

  if (!response.ok) {
    throw new Error('Failed to get part images');
  }

  const data = await response.json();

  // Return the images array from the web search response
  return data.images || [];
}
