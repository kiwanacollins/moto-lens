/**
 * Vincario (VinDecoder.eu) API Service
 * 
 * European-focused VIN decoding service with excellent German vehicle support
 * API Documentation: https://vindecoder.eu/api/
 * 
 * Advantages:
 * - Excellent European/German vehicle support (99.3% accuracy)
 * - Free tier: 10 requests/day
 * - Paid plans: €29/month for 1,000 requests
 * - Superior handling of VIN format issues
 * - Comprehensive vehicle database (73M+ VINs)
 */

import axios from 'axios';

const VINCARIO_API_BASE = 'https://vindecoder.eu/api';

/**
 * Decode a VIN using Vincario API  
 * @param {string} vin - 17-character Vehicle Identification Number
 * @returns {Promise<Object>} Decoded vehicle data
 */
export async function decodeVIN(vin) {
    const apiKey = process.env.VINCARIO_API_KEY;

    if (!apiKey) {
        throw new VINDecodeError(
            'VINCARIO_API_KEY is not configured',
            'API_KEY_MISSING',
            500
        );
    }

    try {
        const response = await axios.get(`${VINCARIO_API_BASE}/vin/${vin}`, {
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'Content-Type': 'application/json',
                'User-Agent': 'MotoLens/1.0.0 (Garage Management Tool)',
            },
            timeout: 15000, // 15 second timeout (European servers can be slower)
        });

        return response.data;
    } catch (error) {
        // Handle specific API errors
        if (error.response) {
            const { status, data } = error.response;

            if (status === 400) {
                throw new VINDecodeError(
                    data.message || 'Invalid VIN format',
                    'INVALID_VIN_FORMAT',
                    400
                );
            }

            if (status === 404) {
                throw new VINDecodeError(
                    'VIN not found in Vincario database',
                    'VIN_NOT_FOUND',
                    404
                );
            }

            if (status === 401 || status === 403) {
                throw new VINDecodeError(
                    'Vincario API authentication failed - check your API key',
                    'AUTH_FAILED',
                    status
                );
            }

            if (status === 429) {
                throw new VINDecodeError(
                    'Vincario API rate limit exceeded',
                    'RATE_LIMITED',
                    429
                );
            }

            throw new VINDecodeError(
                data.message || `Vincario API returned status ${status}`,
                'API_ERROR',
                status
            );
        }

        // Network errors
        if (error.code === 'ECONNABORTED') {
            throw new VINDecodeError(
                'Vincario API request timed out',
                'TIMEOUT',
                504
            );
        }

        if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
            throw new VINDecodeError(
                'Unable to connect to Vincario API',
                'CONNECTION_ERROR',
                503
            );
        }

        throw new VINDecodeError(
            error.message || 'Vincario API error occurred',
            'UNKNOWN_ERROR',
            500
        );
    }
}

/**
 * Parse Vincario response into clean VehicleData format
 * @param {Object} vincarioResponse - Raw Vincario API response
 * @param {string} originalVin - The original VIN submitted (to preserve)
 * @returns {Object} Cleaned VehicleData object
 */
export function parseVehicleData(vincarioResponse, originalVin = null) {
    // Decide operation and balance format varies between Vincario API versions
    const data = vincarioResponse.decode || vincarioResponse;

    if (!data || typeof data !== 'object') {
        throw new VINDecodeError(
            'Invalid Vincario response structure',
            'INVALID_RESPONSE',
            500
        );
    }

    // Use original VIN if provided, otherwise use API response
    const vinToUse = originalVin || data.vin || data.VIN || '';

    return {
        // Core identification - use original VIN to preserve it
        vin: vinToUse,
        vinValid: data.valid !== false && data.error !== true, // Vincario uses different validity indicators

        // Basic vehicle info
        make: data.make || data.brand || 'Unknown',
        model: data.model || null,
        year: parseInt(data.year) || extractYearFromVIN(data.vin) || null,
        trim: data.trim || data.variant || data.version || null,

        // Technical specifications
        engine: buildEngineDescription(data),
        bodyType: data.bodyType || data.category || data.type || null,
        transmission: data.transmission || null,
        drivetrain: data.drive || data.drivetrain || null,

        // Manufacturer info
        manufacturer: data.manufacturer || data.make || data.brand || 'Unknown',
        origin: data.country || determineOrigin(data.make || data.brand),

        // VIN metadata
        wmi: data.wmi || data.vin?.substring(0, 3) || '',
        checksum: data.checksum !== false && !data.checksumError,

        // Additional details
        style: data.style || data.series || null,
        doors: parseInt(data.doors) || null,
        seats: parseInt(data.seats) || null,
        fuelType: data.fuel || data.fuelType || null,
        displacement: parseFloat(data.displacement) || parseFloat(data.engineSize) || null,
        cylinders: parseInt(data.cylinders) || null,
        horsepower: data.power || data.horsepower || null,
        torque: data.torque || null,

        // Vincario-specific data
        marketPrice: data.price || null,
        euroNCAP: data.euroNCAP || null,

        // Source attribution
        _source: 'vincario',

        // Raw data for debugging (only in development)
        _raw: process.env.NODE_ENV === 'development' ? vincarioResponse : undefined,
    };
}

/**
 * Build engine description from Vincario data
 * @param {Object} data - Parsed Vincario data
 * @returns {string|null} Engine description
 */
function buildEngineDescription(data) {
    const components = [];

    if (data.displacement || data.engineSize) {
        const displacement = parseFloat(data.displacement || data.engineSize);
        if (displacement > 50) {
            // Convert CC to liters
            components.push(`${(displacement / 1000).toFixed(1)}L`);
        } else if (displacement > 0) {
            components.push(`${displacement}L`);
        }
    }

    if (data.fuelType || data.fuel) {
        const fuel = (data.fuelType || data.fuel).toLowerCase();
        if (fuel.includes('diesel')) {
            components.push('diesel');
        } else if (fuel.includes('petrol') || fuel.includes('gasoline')) {
            components.push('petrol');
        } else if (fuel.includes('electric')) {
            components.push('electric');
        } else if (fuel.includes('hybrid')) {
            components.push('hybrid');
        }
    }

    if (data.cylinders) {
        components.push(`${data.cylinders}-cylinder`);
    }

    if (data.turbo === true || (typeof data.turbo === 'string' && data.turbo.toLowerCase() === 'yes')) {
        components.push('turbo');
    }

    return components.length > 0 ? components.join(' ') : null;
}

/**
 * Determine vehicle origin from manufacturer data
 * @param {string} make - Vehicle make
 * @returns {string} Country of origin
 */
function determineOrigin(make) {
    const makeUpper = (make || '').toUpperCase();

    // German manufacturers
    if (['BMW', 'AUDI', 'MERCEDES', 'MERCEDES-BENZ', 'VOLKSWAGEN', 'PORSCHE', 'OPEL'].includes(makeUpper)) {
        return 'Germany';
    }

    // French manufacturers
    if (['PEUGEOT', 'CITROEN', 'RENAULT'].includes(makeUpper)) {
        return 'France';
    }

    // Italian manufacturers
    if (['FIAT', 'ALFA ROMEO', 'FERRARI', 'LAMBORGHINI', 'MASERATI'].includes(makeUpper)) {
        return 'Italy';
    }

    // Japanese manufacturers
    if (['TOYOTA', 'HONDA', 'NISSAN', 'MAZDA', 'SUBARU', 'MITSUBISHI', 'LEXUS', 'INFINITI', 'ACURA'].includes(makeUpper)) {
        return 'Japan';
    }

    // South Korean manufacturers
    if (['HYUNDAI', 'KIA', 'GENESIS'].includes(makeUpper)) {
        return 'South Korea';
    }

    // Swedish manufacturers
    if (['VOLVO', 'SAAB'].includes(makeUpper)) {
        return 'Sweden';
    }

    // American manufacturers
    if (['FORD', 'CHEVROLET', 'GMC', 'CADILLAC', 'CHRYSLER', 'JEEP', 'DODGE', 'LINCOLN', 'BUICK'].includes(makeUpper)) {
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
 * Custom error class for Vincario VIN decode errors
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