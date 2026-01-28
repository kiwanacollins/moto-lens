// Parts service layer - API calls for part-related operations
import type { PartInfo, SparePart } from '../types/parts';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3001/api';

/**
 * Interface for part details response including image
 */
export interface PartDetailsResponse {
  success: boolean;
  partId: string;
  partName: string;
  vehicle?: any;
  image?: {
    url: string;
    title?: string;
    source?: string;
  } | null;
  description: string;
  function?: string;
  symptoms: string[];
  spareParts: any[];
  partNumber: string;
  imageSource: string;
  descriptionSource: string;
  generatedAt: string;
}

/**
 * Fetches comprehensive part details with image and AI-generated description
 */
export async function getPartDetails(
  partName: string,
  partId?: string,
  vehicleData?: any
): Promise<PartDetailsResponse> {
  const response = await fetch(`${API_BASE_URL}/parts/details`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      partName,
      partId,
      vehicleData,
    }),
  });

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.message || 'Failed to fetch part details');
  }

  return response.json();
}

/**
 * Identifies a part and returns detailed information
 */
export async function identifyPart(partName: string, vehicleInfo: object): Promise<PartInfo> {
  const response = await fetch(`${API_BASE_URL}/parts/identify`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ partName, vehicleInfo }),
  });

  if (!response.ok) {
    throw new Error('Failed to identify part');
  }

  return response.json();
}

/**
 * Gets spare parts information for a given part
 */
export async function getSpareParts(partName: string, vehicleInfo: object): Promise<SparePart[]> {
  const response = await fetch(`${API_BASE_URL}/parts/spare-parts`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ partName, vehicleInfo }),
  });

  if (!response.ok) {
    throw new Error('Failed to get spare parts');
  }

  return response.json();
}
