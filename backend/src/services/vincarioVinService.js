/**
 * Vincario VIN Decode API v3.2 Service
 * 
 * Professional VIN decoding service with excellent global vehicle coverage
 * API Documentation: https://vincario.com/api-docs/3.2/
 * 
 * Advantages:
 * - Comprehensive global vehicle database (100M+ VINs)
 * - High accuracy for all vehicle manufacturers
 * - Professional API with robust authentication
 * - Support for multiple data formats
 * - Real-time vehicle data
 * 
 * Authentication: SHA1 control sum based on VIN|ID|API_key|Secret_key
 */

import axios from 'axios';
import crypto from 'crypto';

const VINCARIO_API_BASE = 'https://api.vincario.com/3.2';

/**
 * Generate SHA1 control sum for Vincario API authentication
 * @param {string} vin - Vehicle Identification Number (uppercase)
 * @param {string} apiKey - API key
 * @param {string} secretKey - Secret key
 * @param {string} operationId - Operation ID (e.g., 'decode')
 * @returns {string} First 10 characters of SHA1 hash
 */
function generateControlSum(vin, apiKey, secretKey, operationId = 'decode') {
    const vinUppercase = vin.toUpperCase();
    const dataString = `${vinUppercase}|${operationId}|${apiKey}|${secretKey}`;

    const hash = crypto.createHash('sha1').update(dataString).digest('hex');
    return hash.substring(0, 10);
}

/**
 * Decode a VIN using Vincario API v3.2
 * @param {string} vin - 17-character Vehicle Identification Number
 * @returns {Promise<Object>} Decoded vehicle data
 */
export async function decodeVIN(vin) {
    const apiKey = process.env.VINCARIO_API_KEY;
    const secretKey = process.env.VINCARIO_SECRET_KEY;

    if (!apiKey || !secretKey) {
        throw new VINDecodeError(
            'Vincario API credentials are not configured. Please set VINCARIO_API_KEY and VINCARIO_SECRET_KEY',
            'API_CREDENTIALS_MISSING',
            500
        );
    }

    if (!vin || typeof vin !== 'string' || vin.length !== 17) {
        throw new VINDecodeError(
            'VIN must be a 17-character string',
            'INVALID_VIN_FORMAT',
            400
        );
    }

    try {
        // Generate control sum for authentication
        const controlSum = generateControlSum(vin, apiKey, secretKey, 'decode');

        // Build API URL with authentication parameters
        const apiUrl = `${VINCARIO_API_BASE}/${apiKey}/${controlSum}/decode/${vin.toUpperCase()}.json`;

        console.log(`🔍 Vincario API: Decoding VIN ${vin}`);
        console.log(`📍 API URL: ${VINCARIO_API_BASE}/${apiKey}/${controlSum}/decode/{VIN}.json`);

        const response = await axios.get(apiUrl, {
            timeout: 15000, // 15 second timeout
            headers: {
                'User-Agent': 'MotoLens/1.0.0 (Professional Vehicle Diagnostics Tool)',
                'Accept': 'application/json',
                'Cache-Control': 'no-cache'
            },
        });

        if (!response.data) {
            throw new VINDecodeError(
                'Empty response from Vincario API',
                'EMPTY_RESPONSE',
                500
            );
        }

        console.log(`✅ Vincario API: Successfully decoded VIN`);
        return response.data;
    } catch (error) {
        console.log(`❌ Vincario API error: ${error.message}`);

        // Handle specific HTTP error responses
        if (error.response) {
            const { status, data } = error.response;

            if (status === 400) {
                throw new VINDecodeError(
                    'Invalid VIN format or parameters for Vincario API',
                    'INVALID_VIN_FORMAT',
                    400
                );
            }

            if (status === 401 || status === 403) {
                throw new VINDecodeError(
                    'Vincario API authentication failed - check your API key and secret key',
                    'AUTH_FAILED',
                    status
                );
            }

            if (status === 404) {
                throw new VINDecodeError(
                    'VIN not found in Vincario database',
                    'VIN_NOT_FOUND',
                    404
                );
            }

            if (status === 429) {
                throw new VINDecodeError(
                    'Vincario API rate limit exceeded',
                    'RATE_LIMITED',
                    429
                );
            }

            if (status === 402) {
                throw new VINDecodeError(
                    'Vincario API quota exceeded - please check your account balance',
                    'QUOTA_EXCEEDED',
                    402
                );
            }

            throw new VINDecodeError(
                data?.error || data?.message || `Vincario API returned status ${status}`,
                'API_ERROR',
                status
            );
        }

        // Handle network/timeout errors
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
    // Vincario v3.2 returns data as an array under 'decode' key
    const decodeArray = vincarioResponse.decode || [];

    // Convert array format to object for easier access
    const data = {};
    decodeArray.forEach(item => {
        if (item.label && item.value !== undefined) {
            data[item.label] = item.value;
        }
    });

    // Check if the response indicates an error
    if (vincarioResponse.error || vincarioResponse.Error) {
        throw new VINDecodeError(
            vincarioResponse.error || vincarioResponse.Error || 'Vincario API returned an error',
            'API_RESPONSE_ERROR',
            400
        );
    }

    // Use original VIN if provided, otherwise extract from response
    const vinToUse = originalVin || data['VIN'] || '';

    // Determine VIN validity
    const vinValid = !vincarioResponse.error && data['VIN'] && data['VIN'].length === 17;

    return {
        // Core identification
        vin: vinToUse,
        vinValid,

        // Basic vehicle information
        make: data['Make'] || 'Unknown',
        model: data['Model'] || null,
        year: parseYear(data['Model Year']),
        trim: data['Trim'] || data['Series'] || data['Version'] || null,

        // Technical specifications
        engine: buildEngineDescription(data),
        bodyType: data['Body'] || data['Product Type'] || null,
        transmission: data['Transmission'] || null,
        drivetrain: data['Drive'] || null,

        // Manufacturer information
        manufacturer: data['Manufacturer'] || data['Make'] || 'Unknown',
        origin: determineOrigin(data['Make']),

        // VIN metadata
        wmi: data['VIN']?.substring(0, 3) || vinToUse.substring(0, 3) || '',
        checksum: data['Check Digit'] ? true : null,

        // Additional vehicle details
        style: data['Series'] || data['Variant'] || null,
        doors: parseInteger(data['Number of Doors']),
        seats: parseInteger(data['Number of Seats']),
        fuelType: data['Fuel Type - Primary'] || null,
        displacement: parseFloat(data['Engine Displacement (ccm)']) || null,
        cylinders: parseInteger(data['Engine Cylinders']),
        horsepower: parseFloat(data['Engine Power (HP)']),
        torque: parseFloat(data['Engine Torque (Nm)']),

        // Physical specifications
        length: parseInteger(data['Length (mm)']),
        width: parseInteger(data['Width (mm)']),
        height: parseInteger(data['Height (mm)']),
        wheelbase: parseInteger(data['Wheelbase (mm)']),
        weight: parseInteger(data['Weight Empty (kg)']),

        // Additional Vincario-specific data
        plantCity: data['Plant City'] || null,
        plantCountry: data['Plant Country'] || null,
        productionStarted: parseInteger(data['Production Started']),
        productionStopped: parseInteger(data['Production Stopped']),
        maxSpeed: parseInteger(data['Max Speed (km/h)']),
        maxWeight: parseInteger(data['Max Weight (kg)']),
        co2Emission: parseFloat(data['Average CO2 Emission (g/km)']),
        wheelSize: data['Wheel Size'] || null,
        airConditioning: data['Air Conditioning'] || null,

        // Vincario-specific data
        marketPrice: data.price || null,
        euroNCAP: data.euroNCAP || null,

        // Source attribution
        _source: 'vincario-v3.2',

        // Raw data for debugging (only in development)
        _raw: process.env.NODE_ENV === 'development' ? vincarioResponse : undefined,
    };
}

/**
 * Build comprehensive engine description from Vincario data
 * @param {Object} data - Vincario response data
 * @returns {string|null} Engine description
 */
function buildEngineDescription(data) {
    const components = [];

    // Engine displacement
    const displacement = parseFloat(data['Engine Displacement (ccm)']) || parseFloat(data['Engine Displacement']);
    if (displacement > 0) {
        if (displacement >= 1000) {
            components.push(`${(displacement / 1000).toFixed(1)}L`);
        } else {
            components.push(`${displacement}cc`);
        }
    }

    // Engine type
    if (data['Engine Type']) {
        components.push(data['Engine Type']);
    }

    // Cylinder count
    const cylinders = parseInteger(data['Engine Cylinders']);
    if (cylinders > 0) {
        components.push(`${cylinders}-cylinder`);
    }

    // Cylinder configuration
    if (data['Engine Cylinders Position']) {
        components.push(data['Engine Cylinders Position'].toLowerCase());
    }

    // Fuel type
    const fuelType = data['Fuel Type - Primary'] || data['Fuel Type'];
    if (fuelType) {
        const fuel = fuelType.toLowerCase();
        if (fuel.includes('diesel')) {
            components.push('diesel');
        } else if (fuel.includes('gasoline') || fuel.includes('petrol')) {
            components.push('gasoline');
        } else if (fuel.includes('electric')) {
            components.push('electric');
        } else if (fuel.includes('hybrid')) {
            components.push('hybrid');
        }
    }

    // Turbocharged
    if (data['Engine Turbine'] && data['Engine Turbine'].toLowerCase().includes('turbo')) {
        components.push('turbo');
    }

    // Power rating
    const power = parseFloat(data['Engine Power (HP)']);
    if (power > 0) {
        components.push(`${Math.round(power)}hp`);
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
 * Safely parse year from various formats
 * @param {any} yearValue - Year value from API
 * @returns {number|null} Parsed year
 */
function parseYear(yearValue) {
    if (!yearValue) return null;

    // Handle date strings (e.g., "2008-01-21")
    if (typeof yearValue === 'string' && yearValue.includes('-')) {
        const year = parseInt(yearValue.split('-')[0]);
        return (year >= 1900 && year <= 2030) ? year : null;
    }

    const year = parseInt(yearValue);
    return (year >= 1900 && year <= 2030) ? year : null;
}

/**
 * Safely parse integer values
 * @param {any} value - Value to parse
 * @returns {number|null} Parsed integer or null
 */
function parseInteger(value) {
    if (!value) return null;
    const parsed = parseInt(value);
    return isNaN(parsed) ? null : parsed;
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