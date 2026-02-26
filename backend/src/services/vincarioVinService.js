/**
 * Vincario VIN Decoder API v3.2 Service
 *
 * VIN decoding via the Vincario API — specialist European vehicle decoder.
 * API Documentation: https://vincario.com/api-docs/3.2/
 *
 * Authentication: HMAC-style control sum
 *   control_sum = sha1(VIN + "|" + "decode" + "|" + VINCARIO_SECRET_KEY).substring(0, 8)
 * Request URL: https://api.vindecoder.eu/3.2/{VINCARIO_API_KEY}/{control_sum}/decode/{VIN}.json
 *
 * Credentials are read from VINCARIO_API_KEY and VINCARIO_SECRET_KEY env vars.
 */

import crypto from 'crypto';

const VINCARIO_API_BASE = 'https://api.vindecoder.eu/3.2';

/**
 * Compute the Vincario request control sum.
 * @param {string} vin - Uppercase 17-char VIN
 * @param {string} secretKey - VINCARIO_SECRET_KEY
 * @returns {string} First 8 hex characters of SHA-1 digest
 */
function buildControlSum(vin, secretKey) {
    return crypto
        .createHash('sha1')
        .update(`${vin}|decode|${secretKey}`)
        .digest('hex')
        .substring(0, 8);
}

/**
 * Decode a VIN using the Vincario API v3.2
 * @param {string} vin - 17-character Vehicle Identification Number
 * @returns {Promise<Object>} Raw API response ({ decode: [...] })
 */
export async function decodeVIN(vin) {
    const apiKey = process.env.VINCARIO_API_KEY;
    const secretKey = process.env.VINCARIO_SECRET_KEY;

    if (!apiKey || !secretKey) {
        throw new VINDecodeError(
            'Vincario API credentials are not configured. Please set VINCARIO_API_KEY and VINCARIO_SECRET_KEY.',
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

    const vinUpper = vin.toUpperCase();
    const controlSum = buildControlSum(vinUpper, secretKey);
    const url = `${VINCARIO_API_BASE}/${apiKey}/${controlSum}/decode/${encodeURIComponent(vinUpper)}.json`;
    console.log(`🔍 Vincario: Decoding VIN ${vinUpper}`);

    let response;
    try {
        response = await fetch(url, {
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'User-Agent': 'GermanCarMedic/1.0.0',
            },
            signal: AbortSignal.timeout(15000),
        });
    } catch (error) {
        if (error.name === 'TimeoutError' || error.name === 'AbortError') {
            throw new VINDecodeError('Vincario API request timed out', 'TIMEOUT', 504);
        }
        throw new VINDecodeError(
            `Unable to connect to Vincario API: ${error.message}`,
            'CONNECTION_ERROR',
            503
        );
    }

    if (!response.ok) {
        const body = await response.text().catch(() => '');
        if (response.status === 401 || response.status === 403) {
            throw new VINDecodeError(
                'Vincario API authentication failed — check VINCARIO_API_KEY and VINCARIO_SECRET_KEY',
                'AUTH_FAILED',
                response.status
            );
        }
        if (response.status === 404) {
            throw new VINDecodeError('VIN not found in Vincario database', 'VIN_NOT_FOUND', 404);
        }
        if (response.status === 429) {
            throw new VINDecodeError('Vincario API rate limit exceeded', 'RATE_LIMITED', 429);
        }
        throw new VINDecodeError(
            `Vincario API returned status ${response.status}: ${body}`,
            'API_ERROR',
            response.status
        );
    }

    const data = await response.json();
    if (!data || !Array.isArray(data.decode)) {
        throw new VINDecodeError('Empty or unexpected response from Vincario API', 'EMPTY_RESPONSE', 500);
    }

    console.log(`✅ Vincario: Successfully decoded VIN (${data.decode.length} fields)`);
    return data;
}

/**
 * Convert the Vincario decode array into a lookup map keyed by label.
 * @param {Array} decodeArray - Array of { label, value } objects
 * @returns {Object} Map of label → value
 */
function buildFieldMap(decodeArray) {
    const map = {};
    for (const item of decodeArray) {
        if (item && item.label != null) {
            map[item.label] = item.value ?? null;
        }
    }
    return map;
}

/**
 * Parse Vincario API v3.2 response into the standard VehicleData format.
 *
 * @param {Object} rawResponse - Raw Vincario API response ({ decode: [...] })
 * @param {string} originalVin - The original VIN submitted
 * @returns {Object} Normalised VehicleData object
 */
export function parseVehicleData(rawResponse, originalVin = null) {
    if (!rawResponse || !Array.isArray(rawResponse.decode)) {
        throw new VINDecodeError(
            'Invalid Vincario response structure',
            'INVALID_RESPONSE',
            500
        );
    }

    const f = buildFieldMap(rawResponse.decode);

    const vinToUse = originalVin || f['VIN'] || '';
    const vinValid = vinToUse.length === 17;
    const make = f['Make'] || f['Manufacturer'] || 'Unknown';

    // Engine description assembled from Vincario fields
    const engine = buildEngineDescription(f);

    const year = parseYear(f['Model Year']);

    return {
        // Core identification
        vin: vinToUse,
        vinValid,

        // Basic vehicle information
        make,
        model: f['Model'] || null,
        year,
        trim: f['Trim'] || f['Version'] || null,

        // Technical specifications
        engine,
        bodyType: f['Body'] || f['Body Type'] || null,
        transmission: f['Transmission'] || f['Gearbox'] || null,
        drivetrain: f['Drive'] || f['Drive Type'] || null,

        // Manufacturer information
        manufacturer: f['Manufacturer'] || make,
        origin: f['Country of Origin'] || f['Assembly Plant Country'] || determineOrigin(make),

        // VIN metadata
        wmi: vinToUse.substring(0, 3) || '',
        checksum: null,

        // Additional vehicle details
        style: f['Trim'] || f['Version'] || null,
        doors: parseInteger(f['Number Of Doors'] || f['Doors']),
        seats: parseInteger(f['Number Of Seats'] || f['Seats']),
        fuelType: f['Fuel Type'] || null,
        displacement: parseInteger(f['Engine Displacement (ccm)'] || f['Engine Displacement']),
        cylinders: parseInteger(f['Number Of Cylinders'] || f['Cylinders']),
        horsepower: parseFloat(f['Power (HP)'] || f['Engine Power (HP)']) || null,
        torque: parseFloat(f['Torque (Nm)']) || null,

        // Physical specifications
        length: parseFloat(f['Length (mm)']) || null,
        width: parseFloat(f['Width (mm)']) || null,
        height: parseFloat(f['Height (mm)']) || null,
        wheelbase: parseFloat(f['Wheelbase (mm)']) || null,
        weight: parseFloat(f['Curb Weight (kg)'] || f['Weight (kg)']) || null,

        // Location data
        plantCity: f['Assembly Plant City'] || null,
        plantCountry: f['Assembly Plant Country'] || null,

        // Source attribution
        _source: 'vincario-3.2',

        // Raw fields for debugging (only in development)
        _raw: process.env.NODE_ENV === 'development' ? f : undefined,
    };
}

/**
 * Build engine description string from Vincario fields.
 */
function buildEngineDescription(f) {
    const components = [];

    const dispCcm = parseInteger(f['Engine Displacement (ccm)'] || f['Engine Displacement']);
    if (dispCcm > 0) {
        const dispL = (dispCcm / 1000).toFixed(1);
        components.push(`${dispL}L`);
    }

    const cylinders = parseInteger(f['Number Of Cylinders'] || f['Cylinders']);
    if (cylinders > 0) components.push(`${cylinders}-cylinder`);

    const fuel = (f['Fuel Type'] || '').toLowerCase();
    if (fuel.includes('diesel')) components.push('diesel');
    else if (fuel.includes('gasoline') || fuel.includes('petrol')) components.push('petrol');
    else if (fuel.includes('electric')) components.push('electric');
    else if (fuel.includes('hybrid')) components.push('hybrid');

    const hp = parseFloat(f['Power (HP)'] || f['Engine Power (HP)']);
    if (hp > 0) components.push(`${Math.round(hp)}hp`);

    return components.length > 0 ? components.join(' ') : null;
}

function determineOrigin(make) {
    const makeUpper = (make || '').toUpperCase();
    if (['BMW', 'AUDI', 'MERCEDES', 'MERCEDES-BENZ', 'VOLKSWAGEN', 'PORSCHE', 'OPEL'].includes(makeUpper)) return 'Germany';
    if (['PEUGEOT', 'CITROEN', 'RENAULT'].includes(makeUpper)) return 'France';
    if (['FIAT', 'ALFA ROMEO', 'FERRARI', 'LAMBORGHINI', 'MASERATI'].includes(makeUpper)) return 'Italy';
    if (['TOYOTA', 'HONDA', 'NISSAN', 'MAZDA', 'SUBARU', 'MITSUBISHI', 'LEXUS', 'INFINITI', 'ACURA'].includes(makeUpper)) return 'Japan';
    if (['HYUNDAI', 'KIA', 'GENESIS'].includes(makeUpper)) return 'South Korea';
    if (['VOLVO', 'SAAB'].includes(makeUpper)) return 'Sweden';
    if (['FORD', 'CHEVROLET', 'GMC', 'CADILLAC', 'CHRYSLER', 'JEEP', 'DODGE', 'LINCOLN', 'BUICK'].includes(makeUpper)) return 'United States';
    return 'Unknown';
}

function parseYear(yearValue) {
    if (!yearValue) return null;
    const year = parseInt(yearValue);
    return (year >= 1900 && year <= 2030) ? year : null;
}

function parseInteger(value) {
    if (!value) return null;
    const parsed = parseInt(value);
    return isNaN(parsed) ? null : parsed;
}

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