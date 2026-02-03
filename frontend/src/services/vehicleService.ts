// Vehicle service layer - API calls for vehicle-related operations
import type { VehicleData, VehicleSummary, VehicleImage } from '../types/vehicle';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3001/api';

/**
 * Decodes a VIN and returns vehicle information
 * Note: Only basic validation is done here - backend handles full validation
 */
export async function decodeVIN(vin: string): Promise<VehicleData> {
  // Only do basic length validation - backend has the authority for full validation
  const trimmedVin = vin.trim().toUpperCase();
  if (trimmedVin.length !== 17) {
    throw new Error('VIN must be exactly 17 characters');
  }

  const response = await fetch(`${API_BASE_URL}/vin/decode`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ vin: trimmedVin }),
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    const errorMessage = errorData.message || `Failed to decode VIN (${response.status})`;
    const inputVin = errorData.vinInput;

    // Provide specific feedback for VIN validation issues
    if (response.status === 400 && errorData.error === 'Invalid VIN' && inputVin) {
      throw new Error(`${errorMessage}\n\nVIN entered: ${inputVin}`);
    }

    throw new Error(errorMessage);
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
 * Note: VIN validation already done in decodeVIN(), no need to re-validate here
 */
export async function getVehicleSummary(vehicleData: VehicleData): Promise<VehicleSummary> {
  // Use the original VIN from the vehicle data, but prefer the URL-encoded original
  // Note: vehicleData.vin might be modified by NHTSA (e.g., with ! for error positions)
  // So we use the VIN as-is for the API call - backend will handle validation
  const originalVin = vehicleData.vin || '';

  // URL encode the VIN to handle special characters
  const encodedVin = encodeURIComponent(originalVin);
  const response = await fetch(`${API_BASE_URL}/vehicle/summary/${encodedVin}`, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    const errorMessage = errorData.message || `Failed to get vehicle summary (${response.status})`;
    const inputVin = errorData.vinInput;

    // Provide specific feedback for VIN validation issues
    if (response.status === 400 && errorData.error === 'Invalid VIN' && inputVin) {
      throw new Error(`${errorMessage}\n\nVIN entered: ${inputVin}`);
    }

    throw new Error(errorMessage);
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
