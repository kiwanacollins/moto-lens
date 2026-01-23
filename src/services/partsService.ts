// Parts service layer - API calls for part-related operations
import type { PartInfo, SparePart } from '../types/parts';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000/api';

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
