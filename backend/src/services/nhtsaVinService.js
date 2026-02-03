/**
 * NHTSA vPIC API Service
 * 
 * Free, government-backed VIN decoding service from US Department of Transportation
 * API Documentation: https://vpic.nhtsa.dot.gov/api/
 * 
 * Advantages:
 * - 100% FREE (no API key required)
 * - Government reliability (99.9% uptime)
 * - Excellent German vehicle support
 * - Multiple output formats (JSON, XML, CSV)
 * - Batch decoding capability
 */

import axios from 'axios';

const NHTSA_API_BASE = 'https://vpic.nhtsa.dot.gov/api/vehicles';

/**
 * Decode a VIN using NHTSA vPIC API
 * @param {string} vin - 17-character Vehicle Identification Number
 * @returns {Promise<Object>} Decoded vehicle data
 */
export async function decodeVIN(vin) {
    try {
        const response = await axios.get(`${NHTSA_API_BASE}/decodevin/${vin}?format=json`, {
            timeout: 10000, // 10 second timeout
            headers: {
                'User-Agent': 'MotoLens/1.0.0 (Garage Management Tool)',
            },
        });

        if (!response.data || !response.data.Results) {
            throw new VINDecodeError(
                'Invalid response format from NHTSA API',
                'INVALID_RESPONSE',
                500
            );
        }

        return response.data;
    } catch (error) {
        // Handle specific API errors
        if (error.response) {
            const { status } = error.response;

            if (status === 400) {
                throw new VINDecodeError(
                    'Invalid VIN format for NHTSA API',
                    'INVALID_VIN_FORMAT',
                    400
                );
            }

            throw new VINDecodeError(
                `NHTSA API returned status ${status}`,
                'API_ERROR',
                status
            );
        }

        // Network errors
        if (error.code === 'ECONNABORTED') {
            throw new VINDecodeError(
                'NHTSA API request timed out',
                'TIMEOUT',
                504
            );
        }

        if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
            throw new VINDecodeError(
                'Unable to connect to NHTSA API',
                'CONNECTION_ERROR',
                503
            );
        }

        throw new VINDecodeError(
            error.message || 'NHTSA API error occurred',
            'UNKNOWN_ERROR',
            500
        );
    }
}

/**
 * Parse NHTSA vPIC response into clean VehicleData format
 * @param {Object} nhtsaResponse - Raw NHTSA API response
 * @param {string} originalVin - The original VIN submitted (to preserve, not use NHTSA's modified version)
 * @returns {Object} Cleaned VehicleData object
 */
export function parseVehicleData(nhtsaResponse, originalVin = null) {
    if (!nhtsaResponse.Results || !Array.isArray(nhtsaResponse.Results)) {
        throw new VINDecodeError(
            'Invalid NHTSA response structure',
            'INVALID_RESPONSE',
            500
        );
    }

    // Convert array of key-value pairs to object
    const data = {};
    nhtsaResponse.Results.forEach(item => {
        if (item.Variable && item.Value !== null && item.Value !== '') {
            data[item.Variable] = item.Value;
        }
    });

    // Extract error information
    const errorCodes = data['Error Code']?.split(',') || [];
    const hasErrors = errorCodes.some(code => code.trim() !== '');
    const errorText = data['Error Text'] || '';
    const additionalErrorText = data['Additional Error Text'] || '';

    // Determine VIN validity based on error codes
    const vinValid = !hasErrors || (!errorCodes.includes('1') && !errorCodes.includes('400'));

    // IMPORTANT: Always use the original VIN, NOT the "Suggested VIN" from NHTSA
    // NHTSA's "Suggested VIN" replaces invalid positions with '!' characters (e.g., SALV!2!!4EH877322)
    // which breaks subsequent API calls and displays poorly in UI
    const searchCriteriaVin = nhtsaResponse.SearchCriteria?.replace('VIN:', '').trim() || '';
    const vinToUse = originalVin || searchCriteriaVin || data['Suggested VIN'] || '';

    return {
        // Core identification - ALWAYS use original VIN, not NHTSA's modified version
        vin: vinToUse,
        vinValid,
        // Store NHTSA's suggested VIN separately for debugging only
        _suggestedVin: data['Suggested VIN'] || null,

        // Basic vehicle info
        make: data['Make'] || 'Unknown',
        model: data['Model'] || null,
        year: parseInt(data['Model Year']) || extractYearFromVIN(data['Suggested VIN']) || null,
        trim: data['Trim'] || data['Trim2'] || null,

        // Technical specifications
        engine: buildEngineDescription(data),
        bodyType: data['Body Class'] || data['Vehicle Type'] || null,
        transmission: data['Transmission Style'] || null,
        drivetrain: data['Drive Type'] || null,

        // Manufacturer info  
        manufacturer: data['Manufacturer Name'] || data['Make'] || 'Unknown',
        origin: determineOrigin(data['Make'], data['Manufacturer Name']),

        // VIN metadata
        wmi: data['Vehicle Descriptor']?.substring(0, 3) || nhtsaResponse.SearchCriteria?.replace('VIN:', '').substring(0, 3),
        checksum: !errorCodes.includes('1'), // Error code 1 = invalid check digit

        // Additional details
        style: data['Series'] || data['Series2'] || null,
        doors: parseInt(data['Doors']) || null,
        seats: parseInt(data['Number of Seats']) || null,
        fuelType: data['Fuel Type - Primary'] || null,
        displacement: parseFloat(data['Displacement (L)']) || null,
        cylinders: parseInt(data['Engine Number of Cylinders']) || null,

        // Error information (for debugging)
        _errors: hasErrors ? {
            codes: errorCodes,
            text: errorText,
            additionalText: additionalErrorText
        } : null,

        // Source attribution
        _source: 'nhtsa-vpic',

        // Raw data for debugging (only in development)
        _raw: process.env.NODE_ENV === 'development' ? nhtsaResponse : undefined,
    };
}

/**
 * Build engine description from NHTSA data
 * @param {Object} data - Parsed NHTSA data
 * @returns {string} Engine description
 */
function buildEngineDescription(data) {
    const components = [];

    if (data['Displacement (L)']) {
        components.push(`${data['Displacement (L)']}L`);
    }

    if (data['Engine Configuration']) {
        components.push(data['Engine Configuration']);
    }

    if (data['Engine Number of Cylinders']) {
        components.push(`${data['Engine Number of Cylinders']}-cylinder`);
    }

    if (data['Fuel Type - Primary']) {
        components.push(data['Fuel Type - Primary'].toLowerCase());
    }

    if (data['Turbo'] === 'Yes') {
        components.push('turbo');
    }

    return components.length > 0 ? components.join(' ') : null;
}

/**
 * Determine vehicle origin from manufacturer data
 * @param {string} make - Vehicle make
 * @param {string} manufacturer - Manufacturer name
 * @returns {string} Country of origin
 */
function determineOrigin(make, manufacturer) {
    const makeUpper = (make || '').toUpperCase();
    const mfgUpper = (manufacturer || '').toUpperCase();

    // German manufacturers
    if (['BMW', 'AUDI', 'MERCEDES', 'MERCEDES-BENZ', 'VOLKSWAGEN', 'PORSCHE'].includes(makeUpper) ||
        mfgUpper.includes('BMW') || mfgUpper.includes('AUDI') || mfgUpper.includes('MERCEDES') ||
        mfgUpper.includes('VOLKSWAGEN') || mfgUpper.includes('PORSCHE')) {
        return 'Germany';
    }

    // Other common origins
    if (['TOYOTA', 'HONDA', 'NISSAN', 'MAZDA', 'SUBARU', 'MITSUBISHI'].includes(makeUpper)) {
        return 'Japan';
    }

    if (['HYUNDAI', 'KIA', 'GENESIS'].includes(makeUpper)) {
        return 'South Korea';
    }

    if (['FORD', 'CHEVROLET', 'GMC', 'CADILLAC', 'CHRYSLER', 'JEEP', 'DODGE'].includes(makeUpper)) {
        return 'United States';
    }

    return 'Unknown';
}

/**
 * Extract model year from VIN (position 10)
 * @param {string} vin - The VIN
 * @returns {number|null} Model year
 */
function extractYearFromVIN(vin) {
    if (!vin || vin.length < 10) return null;

    const yearCodes = {
        'A': 2010, 'B': 2011, 'C': 2012, 'D': 2013, 'E': 2014,
        'F': 2015, 'G': 2016, 'H': 2017, 'J': 2018, 'K': 2019,
        'L': 2020, 'M': 2021, 'N': 2022, 'P': 2023, 'R': 2024,
        'S': 2025, 'T': 2026, 'V': 2027, 'W': 2028, 'X': 2029,
        'Y': 2030, '1': 2001, '2': 2002, '3': 2003, '4': 2004,
        '5': 2005, '6': 2006, '7': 2007, '8': 2008, '9': 2009,
    };

    return yearCodes[vin[9]] || null;
}

/**
 * Custom error class for NHTSA VIN decode errors
 */
export class VINDecodeError extends Error {
    constructor(message, code, statusCode) {
        super(message);
        this.name = 'VINDecodeError';
        this.code = code;
        this.statusCode = statusCode;
    }
}

export default {
    decodeVIN,
    parseVehicleData,
    VINDecodeError
};