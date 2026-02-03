/**
 * Zyla Labs VIN Decode API Service
 * 
 * VIN decoding service from Zyla Labs
 * API Documentation: https://zylalabs.com/api-marketplace/data/vin+decode+api/14977
 * 
 * Advantages:
 * - Comprehensive vehicle data
 * - Good coverage for various manufacturers
 * - JSON response format
 */

import axios from 'axios';

const ZYLA_API_BASE = 'https://zylalabs.com/api/6580/vin+decode+api/14977/decode';
const ZYLA_API_KEY = process.env.ZYLA_API_KEY || '12165|ibuwBTHZjuefiOEWH3nG6B40VFfjQDUeGKsBaxlQ';

/**
 * Decode a VIN using Zyla Labs VIN Decode API
 * @param {string} vin - 17-character Vehicle Identification Number
 * @returns {Promise<Object>} Decoded vehicle data
 */
export async function decodeVIN(vin) {
    try {
        const response = await axios.get(ZYLA_API_BASE, {
            params: {
                vin: vin
            },
            headers: {
                'Authorization': `Bearer ${ZYLA_API_KEY}`,
                'Content-Type': 'application/json',
            },
            timeout: 30000, // 30 second timeout (Zyla Labs API can be slow)
        });

        if (!response.data) {
            throw new VINDecodeError(
                'Invalid response format from Zyla Labs API',
                'INVALID_RESPONSE',
                500
            );
        }

        // Check for API-level errors
        if (response.data.error) {
            throw new VINDecodeError(
                response.data.error.message || 'Zyla Labs API error',
                'API_ERROR',
                response.data.error.code || 400
            );
        }

        return response.data;
    } catch (error) {
        // Handle axios errors
        if (error.response) {
            const { status, data } = error.response;

            if (status === 400) {
                throw new VINDecodeError(
                    data?.message || 'Invalid VIN format for Zyla Labs API',
                    'INVALID_VIN_FORMAT',
                    400
                );
            }

            if (status === 401 || status === 403) {
                throw new VINDecodeError(
                    'Zyla Labs API authentication failed',
                    'AUTH_ERROR',
                    status
                );
            }

            if (status === 429) {
                throw new VINDecodeError(
                    'Zyla Labs API rate limit exceeded',
                    'RATE_LIMIT',
                    429
                );
            }

            throw new VINDecodeError(
                `Zyla Labs API returned status ${status}`,
                'API_ERROR',
                status
            );
        }

        // Network errors
        if (error.code === 'ECONNABORTED') {
            throw new VINDecodeError(
                'Zyla Labs API request timed out',
                'TIMEOUT',
                504
            );
        }

        if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
            throw new VINDecodeError(
                'Unable to connect to Zyla Labs API',
                'CONNECTION_ERROR',
                503
            );
        }

        // Re-throw if already a VINDecodeError
        if (error.name === 'VINDecodeError') {
            throw error;
        }

        throw new VINDecodeError(
            error.message || 'Zyla Labs API error occurred',
            'UNKNOWN_ERROR',
            500
        );
    }
}

/**
 * Parse Zyla Labs VIN API response into clean VehicleData format
 * @param {Object} zylaResponse - Raw Zyla Labs API response
 * @param {string} originalVin - The original VIN submitted
 * @returns {Object} Cleaned VehicleData object
 */
export function parseVehicleData(zylaResponse, originalVin = null) {
    // Zyla Labs API response structure:
    // {
    //   "Make": "Mercedes-Benz",
    //   "Model": "SL 350",
    //   "Model year": "2003",
    //   "Trim level": "R230",
    //   "Body style": "2 Doors Convertible",
    //   "Engine type": "V6",
    //   "Fuel type": "Gasoline",
    //   "Transmission": "5-Speed Automatic",
    //   "Vehicle type": "Passenger car",
    //   "Manufactured in": "Germany",
    //   "Manufacturer": "Daimler AG",
    //   "Body type": "Convertible",
    //   "Number of doors": "2",
    //   "Number of seats": "5-2",
    //   "Displacement SI": "3724",
    //   "Displacement Nominal": "3.7",
    //   "Engine cylinders": "6",
    //   "Engine HorsePower": "245",
    //   "Driveline": "RWD",
    //   "VIN": "WDB2304671F079293"
    // }

    const data = zylaResponse;

    // Extract make - Zyla provides it directly
    const make = data.Make || data.make || derivesMakeFromManufacturer(data.Manufacturer) || 'Unknown';
    
    // Extract model
    const model = data.Model || data.model || null;
    
    // Extract year - prefer API response, fallback to VIN extraction
    const yearFromApi = parseInt(data['Model year'] || data['Model Year'] || data.year);
    const year = !isNaN(yearFromApi) ? yearFromApi : extractYearFromVIN(originalVin || data.VIN);

    // Build engine description from available data
    const engine = buildEngineDescription(data);
    
    // Extract displacement as number
    const displacementNominal = parseFloat(data['Displacement Nominal'] || data['Displacement (L)']);
    const displacementSI = parseInt(data['Displacement SI']);
    const displacement = !isNaN(displacementNominal) ? displacementNominal : 
                        (!isNaN(displacementSI) ? displacementSI / 1000 : null);

    // Determine VIN validity
    const vinValid = make !== 'Unknown' || model !== null || year !== null;

    return {
        // Core identification
        vin: originalVin || data.VIN || '',
        vinValid,

        // Basic vehicle info
        make: make.toUpperCase(),
        model: model,
        year: year || null,
        trim: data['Trim level'] || data.Trim || null,

        // Technical specifications
        engine: engine,
        bodyType: data['Body style'] || data['Body type'] || data['Vehicle type'] || null,
        transmission: data.Transmission || data['Automatic gearbox'] || null,
        drivetrain: data.Driveline || data.driveline || null,

        // Manufacturer info
        manufacturer: data.Manufacturer || make || 'Unknown',
        origin: data['Manufactured in'] || data.Country || determineOrigin(make, data.Manufacturer),
        manufacturerAddress: data['Adress line 1'] ?
            `${data['Adress line 1']}, ${data['Adress line 2'] || ''}`.trim() : null,
        region: data.Region || null,

        // VIN metadata
        wmi: originalVin ? originalVin.substring(0, 3) : (data.VIN ? data.VIN.substring(0, 3) : null),
        checksum: vinValid,

        // Additional details
        style: data['Body style'] || null,
        doors: parseInt(data['Number of doors']) || null,
        seats: parseSeatCount(data['Number of seats']),
        fuelType: data['Fuel type'] || null,
        displacement: displacement,
        cylinders: parseInt(data['Engine cylinders']) || null,
        
        // Extended engine info
        engineType: data['Engine type'] || null,
        engineHead: data['Engine head'] || null,
        engineValves: parseInt(data['Engine valves']) || null,
        horsepower: parseInt(data['Engine HorsePower']) || null,
        kilowatts: parseInt(data['Engine KiloWatts']) || null,
        
        // Emissions and standards
        emissionStandard: data['Emission standard'] || null,
        vehicleType: data['Vehicle type'] || null,

        // Zyla-specific data
        note: data.Note || null,

        // Source attribution
        _source: 'zyla-labs',

        // Raw data for debugging (only in development)
        _raw: process.env.NODE_ENV === 'development' ? zylaResponse : undefined,
    };
}

/**
 * Parse seat count from Zyla format (e.g., "5-2" means 5 seats, 2 rows)
 * @param {string} seatStr - Seat string from Zyla API
 * @returns {number|null} Number of seats
 */
function parseSeatCount(seatStr) {
    if (!seatStr) return null;
    const parts = String(seatStr).split('-');
    return parseInt(parts[0]) || null;
}

/**
 * Build engine description from Zyla Labs data
 * @param {Object} data - Parsed Zyla Labs data
 * @returns {string|null} Engine description
 */
function buildEngineDescription(data) {
    const components = [];

    // Displacement
    const displacementNominal = data['Displacement Nominal'];
    if (displacementNominal) {
        components.push(`${displacementNominal}L`);
    }

    // Engine type (V6, V8, Inline-4, etc.)
    const engineType = data['Engine type'];
    if (engineType) {
        components.push(engineType);
    }

    // Cylinders (if not already in engine type)
    const cylinders = data['Engine cylinders'];
    if (cylinders && !engineType) {
        components.push(`${cylinders}-cylinder`);
    }

    // Fuel type
    const fuelType = data['Fuel type'];
    if (fuelType) {
        components.push(fuelType.toLowerCase());
    }

    // Horsepower
    const hp = data['Engine HorsePower'];
    if (hp) {
        components.push(`${hp}hp`);
    }

    return components.length > 0 ? components.join(' ') : null;
}

/**
 * Derive make from manufacturer name (fallback when Make field is missing)
 * @param {string} manufacturer - Manufacturer name (e.g., "Daimler AG")
 * @returns {string|null} Vehicle make
 */
function derivesMakeFromManufacturer(manufacturer) {
    if (!manufacturer) return null;

    const mfgUpper = manufacturer.toUpperCase();

    // German manufacturers
    if (mfgUpper.includes('DAIMLER') || mfgUpper.includes('MERCEDES')) {
        return 'MERCEDES-BENZ';
    }
    if (mfgUpper.includes('BAYERISCHE') || mfgUpper.includes('BMW')) {
        return 'BMW';
    }
    if (mfgUpper.includes('AUDI') || (mfgUpper.includes('VOLKSWAGEN') && mfgUpper.includes('AUDI'))) {
        return 'AUDI';
    }
    if (mfgUpper.includes('VOLKSWAGEN') && !mfgUpper.includes('AUDI')) {
        return 'VOLKSWAGEN';
    }
    if (mfgUpper.includes('PORSCHE')) {
        return 'PORSCHE';
    }

    // Japanese manufacturers
    if (mfgUpper.includes('TOYOTA')) return 'TOYOTA';
    if (mfgUpper.includes('HONDA')) return 'HONDA';
    if (mfgUpper.includes('NISSAN')) return 'NISSAN';
    if (mfgUpper.includes('MAZDA')) return 'MAZDA';
    if (mfgUpper.includes('SUBARU')) return 'SUBARU';

    // American manufacturers
    if (mfgUpper.includes('FORD')) return 'FORD';
    if (mfgUpper.includes('GENERAL MOTORS') || mfgUpper.includes('CHEVROLET')) return 'CHEVROLET';
    if (mfgUpper.includes('CHRYSLER') || mfgUpper.includes('STELLANTIS')) return 'CHRYSLER';
    if (mfgUpper.includes('TESLA')) return 'TESLA';

    // Korean manufacturers
    if (mfgUpper.includes('HYUNDAI')) return 'HYUNDAI';
    if (mfgUpper.includes('KIA')) return 'KIA';

    return null;
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

    // Japanese manufacturers
    if (['TOYOTA', 'HONDA', 'NISSAN', 'MAZDA', 'SUBARU', 'MITSUBISHI', 'LEXUS', 'ACURA', 'INFINITI'].includes(makeUpper)) {
        return 'Japan';
    }

    // Korean manufacturers
    if (['HYUNDAI', 'KIA', 'GENESIS'].includes(makeUpper)) {
        return 'South Korea';
    }

    // American manufacturers
    if (['FORD', 'CHEVROLET', 'GMC', 'CADILLAC', 'CHRYSLER', 'JEEP', 'DODGE', 'RAM', 'LINCOLN', 'BUICK', 'TESLA'].includes(makeUpper)) {
        return 'United States';
    }

    // British manufacturers
    if (['JAGUAR', 'LAND ROVER', 'BENTLEY', 'ROLLS-ROYCE', 'ASTON MARTIN', 'MCLAREN', 'MINI'].includes(makeUpper)) {
        return 'United Kingdom';
    }

    // Italian manufacturers
    if (['FERRARI', 'LAMBORGHINI', 'MASERATI', 'ALFA ROMEO', 'FIAT'].includes(makeUpper)) {
        return 'Italy';
    }

    // Swedish manufacturers
    if (['VOLVO', 'SAAB'].includes(makeUpper)) {
        return 'Sweden';
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
 * Custom error class for Zyla Labs VIN decode errors
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
