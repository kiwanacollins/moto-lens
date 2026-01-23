/**
 * Auto.dev API Service
 * 
 * Integrates with Auto.dev VIN Decode API for vehicle information retrieval.
 * API Documentation: https://docs.auto.dev/v2/products/vin-decode
 */

import axios from 'axios';

const AUTODEV_API_BASE = 'https://api.auto.dev';

/**
 * Decode a VIN using Auto.dev API
 * @param {string} vin - 17-character Vehicle Identification Number
 * @returns {Promise<Object>} Decoded vehicle data
 */
export async function decodeVIN(vin) {
    const apiKey = process.env.AUTODEV_API_KEY;

    if (!apiKey) {
        throw new Error('AUTODEV_API_KEY is not configured');
    }

    try {
        const response = await axios.get(`${AUTODEV_API_BASE}/vin/${vin}`, {
            headers: {
                'Authorization': `Bearer ${apiKey}`,
                'Content-Type': 'application/json',
            },
            timeout: 10000, // 10 second timeout
        });

        return response.data;
    } catch (error) {
        // Handle specific API errors
        if (error.response) {
            const { status, data } = error.response;

            if (status === 400) {
                throw new VINDecodeError(
                    data.error || 'Invalid VIN format',
                    'INVALID_VIN_FORMAT',
                    400
                );
            }

            if (status === 404) {
                throw new VINDecodeError(
                    data.error || 'No vehicle data found for this VIN',
                    'VIN_NOT_FOUND',
                    404
                );
            }

            if (status === 401 || status === 403) {
                throw new VINDecodeError(
                    'API authentication failed - check your API key',
                    'AUTH_FAILED',
                    status
                );
            }

            if (status === 429) {
                throw new VINDecodeError(
                    'API rate limit exceeded - please try again later',
                    'RATE_LIMITED',
                    429
                );
            }

            throw new VINDecodeError(
                data.error || `API returned status ${status}`,
                'API_ERROR',
                status
            );
        }

        // Network errors
        if (error.code === 'ECONNABORTED') {
            throw new VINDecodeError(
                'Request timed out - please try again',
                'TIMEOUT',
                504
            );
        }

        if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
            throw new VINDecodeError(
                'Unable to connect to VIN decode service',
                'CONNECTION_ERROR',
                503
            );
        }

        throw new VINDecodeError(
            error.message || 'Unknown error occurred',
            'UNKNOWN_ERROR',
            500
        );
    }
}

/**
 * Parse Auto.dev response into clean VehicleData format
 * @param {Object} apiResponse - Raw Auto.dev API response
 * @returns {Object} Cleaned VehicleData object
 */
export function parseVehicleData(apiResponse) {
    // Extract nested vehicle object for some fields
    const vehicle = apiResponse.vehicle || {};

    return {
        // Core identification
        vin: apiResponse.vin,
        vinValid: apiResponse.vinValid,

        // Basic vehicle info
        make: apiResponse.make || vehicle.make || 'Unknown',
        model: apiResponse.model || vehicle.model || 'Unknown',
        year: vehicle.year || extractYearFromVIN(apiResponse.vin),
        trim: apiResponse.trim || null,

        // Technical specifications
        engine: apiResponse.engine || 'Not specified',
        bodyType: apiResponse.body || apiResponse.style || 'Not specified',
        transmission: apiResponse.transmission || 'Not specified',
        drivetrain: apiResponse.drive || 'Not specified',

        // Manufacturer info
        manufacturer: vehicle.manufacturer || apiResponse.make || 'Unknown',
        origin: apiResponse.origin || 'Unknown',

        // VIN metadata
        wmi: apiResponse.wmi || apiResponse.vin?.substring(0, 3),
        checksum: apiResponse.checksum,

        // Full style description
        style: apiResponse.style || null,

        // Raw data for debugging (only in development)
        _raw: process.env.NODE_ENV === 'development' ? apiResponse : undefined,
    };
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
 * Custom error class for VIN decode errors
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
