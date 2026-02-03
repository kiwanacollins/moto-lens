/**
 * VIN Validation Utility
 * 
 * Validates Vehicle Identification Numbers according to international standards.
 * VINs must be exactly 17 characters, alphanumeric, excluding I, O, Q.
 */

// VIN character set (excludes I, O, Q which can be confused with 1, 0)
const VALID_VIN_CHARS = /^[A-HJ-NPR-Z0-9]{17}$/i;

// VIN transliteration values for checksum calculation
const TRANSLITERATION = {
    A: 1, B: 2, C: 3, D: 4, E: 5, F: 6, G: 7, H: 8,
    J: 1, K: 2, L: 3, M: 4, N: 5, P: 7, R: 9,
    S: 2, T: 3, U: 4, V: 5, W: 6, X: 7, Y: 8, Z: 9,
    0: 0, 1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9
};

// Position weights for checksum calculation
const WEIGHTS = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];

/**
 * Validates VIN format and structure
 * @param {string} vin - The VIN to validate
 * @returns {{ valid: boolean, error?: string }} Validation result
 */
export function validateVIN(vin) {
    if (!vin) {
        return { valid: false, error: 'VIN is required' };
    }

    const upperVIN = vin.toUpperCase().trim();

    // Check length
    if (upperVIN.length !== 17) {
        return {
            valid: false,
            error: `VIN must be exactly 17 characters (received ${upperVIN.length})`
        };
    }

    // Check for invalid characters (I, O, Q)
    if (/[IOQ]/i.test(upperVIN)) {
        return {
            valid: false,
            error: 'VIN cannot contain letters I, O, or Q'
        };
    }

    // Check character set
    if (!VALID_VIN_CHARS.test(upperVIN)) {
        return {
            valid: false,
            error: 'VIN must contain only alphanumeric characters (A-Z, 0-9, excluding I, O, Q)'
        };
    }

    // Validate checksum (position 9)
    const checksumResult = validateChecksum(upperVIN);

    // For now, we'll be lenient with checksum validation since:
    // 1. Many European VINs don't follow US checksum standards  
    // 2. Some older VINs may have different calculation methods
    // 3. The real validation comes from external APIs (NHTSA, etc.)
    if (!checksumResult) {
        console.warn(`VIN checksum validation failed for: ${upperVIN} (may be valid non-US VIN)`);
    }

    return { valid: true, vin: upperVIN };
}

/**
 * Validates VIN checksum (position 9)
 * @param {string} vin - The VIN to validate (must be uppercase)
 * @returns {boolean} Whether checksum is valid
 */
function validateChecksum(vin) {
    let sum = 0;

    for (let i = 0; i < 17; i++) {
        const char = vin[i];
        const value = TRANSLITERATION[char];

        if (value === undefined) {
            return false;
        }

        sum += value * WEIGHTS[i];
    }

    const remainder = sum % 11;
    const checkDigit = vin[8];

    if (remainder === 10) {
        return checkDigit === 'X';
    }

    return checkDigit === String(remainder);
}

/**
 * Extracts World Manufacturer Identifier (WMI) from VIN
 * First 3 characters identify the manufacturer
 * @param {string} vin - The VIN
 * @returns {string} WMI code
 */
export function extractWMI(vin) {
    return vin.toUpperCase().substring(0, 3);
}

/**
 * Identifies German manufacturer from WMI
 * @param {string} vin - The VIN
 * @returns {{ isGerman: boolean, manufacturer?: string }}
 */
export function identifyGermanManufacturer(vin) {
    const wmi = extractWMI(vin);

    // German WMI codes
    const germanWMIs = {
        // BMW
        'WBA': 'BMW',
        'WBS': 'BMW M',
        'WBY': 'BMW i',
        '4US': 'BMW (USA)',
        '5UX': 'BMW X (USA)',
        // Audi
        'WAU': 'Audi',
        'WUA': 'Audi (Quattro GmbH)',
        'WA1': 'Audi SUV',
        'TRU': 'Audi (Hungary)',
        // Mercedes-Benz
        'WDB': 'Mercedes-Benz',
        'WDC': 'Mercedes-Benz (DaimlerChrysler)',
        'WDD': 'Mercedes-Benz',
        'WDF': 'Mercedes-Benz Vans',
        'WMX': 'Mercedes-AMG',
        '4JG': 'Mercedes-Benz (USA)',
        // Volkswagen
        'WVW': 'Volkswagen',
        'WVG': 'Volkswagen (Commercial)',
        'WV1': 'Volkswagen Commercial Vehicles',
        'WV2': 'Volkswagen Bus/Van',
        '3VW': 'Volkswagen (Mexico)',
        '1VW': 'Volkswagen (USA)',
        // Porsche
        'WP0': 'Porsche',
        'WP1': 'Porsche SUV',
    };

    const manufacturer = germanWMIs[wmi];

    if (manufacturer) {
        return { isGerman: true, manufacturer };
    }

    // Check for partial matches (first 2 chars)
    const wmi2 = wmi.substring(0, 2);
    const partialMatches = {
        'WB': 'BMW',
        'WA': 'Audi',
        'WD': 'Mercedes-Benz',
        'WV': 'Volkswagen',
        'WP': 'Porsche',
    };

    const partialMatch = partialMatches[wmi2];
    if (partialMatch) {
        return { isGerman: true, manufacturer: partialMatch };
    }

    return { isGerman: false };
}

export default {
    validateVIN,
    extractWMI,
    identifyGermanManufacturer
};
