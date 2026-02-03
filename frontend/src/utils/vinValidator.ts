// Utility functions for VIN validation and formatting

/**
 * Validates if a VIN is 17 characters long
 */
export function isValidVinLength(vin: string): boolean {
  return vin.length === 17;
}

/**
 * Converts VIN to uppercase
 */
export function formatVin(vin: string): string {
  return vin.toUpperCase().trim();
}

/**
 * Checks if VIN contains only valid characters (excluding I, O, Q)
 */
export function hasValidVinCharacters(vin: string): boolean {
  const validPattern = /^[A-HJ-NPR-Z0-9]{17}$/;
  return validPattern.test(vin.toUpperCase());
}

/**
 * Full VIN validation
 */
export function validateVin(vin: string): { valid: boolean; error?: string } {
  const formatted = formatVin(vin);

  if (!isValidVinLength(formatted)) {
    return { valid: false, error: 'VIN must be exactly 17 characters' };
  }

  if (!hasValidVinCharacters(formatted)) {
    return { valid: false, error: 'VIN contains invalid characters. Only letters A-Z (excluding I, O, Q) and numbers 0-9 are allowed.' };
  }

  return { valid: true };
}
