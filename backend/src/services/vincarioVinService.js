/**
 * TecDoc Catalog VIN Decoder v5 Service
 *
 * VIN decoding via the TecDoc Catalog RapidAPI endpoint.
 * API: https://rapidapi.com/ronhartman/api/tecdoc-catalog
 * Endpoint: GET /vin/decoder-v5/{VIN}
 *
 * Response contains three content objects:
 *  - vin-data-1: WMI/VDS/VIS breakdown, region, country, manufacturer, modelYear
 *  - vin-data-2: Full NHTSA-style vehicle specification
 *  - vin-data-3: Manufacturer information array
 *
 * API key is read from TECDOC_RAPIDAPI_KEY env var.
 */

const RAPIDAPI_HOST = 'tecdoc-catalog.p.rapidapi.com';

/**
 * Safely parse the JSON `content` string from a vin-data-* object.
 * Returns an empty object / array on parse failure.
 */
function parseContent(dataObj) {
    if (!dataObj || !dataObj.content) return null;
    try {
        return JSON.parse(dataObj.content);
    } catch {
        return null;
    }
}

/**
 * Decode a VIN using TecDoc Catalog decoder-v5
 * @param {string} vin - 17-character Vehicle Identification Number
 * @returns {Promise<Object>} Raw API response (keyed by vin-data-1/2/3)
 */
export async function decodeVIN(vin) {
    const apiKey = process.env.TECDOC_RAPIDAPI_KEY;

    if (!apiKey) {
        throw new VINDecodeError(
            'TecDoc RapidAPI key is not configured. Please set TECDOC_RAPIDAPI_KEY',
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

    const url = `https://${RAPIDAPI_HOST}/vin/decoder-v5/${encodeURIComponent(vin.toUpperCase())}`;
    console.log(`🔍 TecDoc decoder-v5: Decoding VIN ${vin}`);

    let response;
    try {
        response = await fetch(url, {
            method: 'GET',
            headers: {
                'x-rapidapi-host': RAPIDAPI_HOST,
                'x-rapidapi-key': apiKey,
            },
            signal: AbortSignal.timeout(15000),
        });
    } catch (error) {
        if (error.name === 'TimeoutError' || error.name === 'AbortError') {
            throw new VINDecodeError('TecDoc API request timed out', 'TIMEOUT', 504);
        }
        throw new VINDecodeError(
            `Unable to connect to TecDoc API: ${error.message}`,
            'CONNECTION_ERROR',
            503
        );
    }

    if (!response.ok) {
        const body = await response.text().catch(() => '');
        if (response.status === 401 || response.status === 403) {
            throw new VINDecodeError(
                'TecDoc API authentication failed - check TECDOC_RAPIDAPI_KEY',
                'AUTH_FAILED',
                response.status
            );
        }
        if (response.status === 404) {
            throw new VINDecodeError('VIN not found in TecDoc database', 'VIN_NOT_FOUND', 404);
        }
        if (response.status === 429) {
            throw new VINDecodeError('TecDoc API rate limit exceeded', 'RATE_LIMITED', 429);
        }
        throw new VINDecodeError(
            `TecDoc API returned status ${response.status}: ${body}`,
            'API_ERROR',
            response.status
        );
    }

    const data = await response.json();
    if (!data) {
        throw new VINDecodeError('Empty response from TecDoc API', 'EMPTY_RESPONSE', 500);
    }

    console.log(`✅ TecDoc decoder-v5: Successfully decoded VIN`);
    return data;
}

/**
 * Parse TecDoc decoder-v5 response into the standard VehicleData format.
 * Only the `content` objects from vin-data-1, vin-data-2 and vin-data-3 are used.
 *
 * @param {Object} rawResponse - Raw TecDoc API response
 * @param {string} originalVin - The original VIN submitted
 * @returns {Object} Normalised VehicleData object
 */
export function parseVehicleData(rawResponse, originalVin = null) {
    // Extract and parse the three content payloads
    const d1 = parseContent(rawResponse['vin-data-1']) || {};
    const d2 = parseContent(rawResponse['vin-data-2']) || {};
    const d3Array = parseContent(rawResponse['vin-data-3']);
    const manuInfo = Array.isArray(d3Array) && d3Array.length > 0
        ? (d3Array[0]?.information || {})
        : {};

    const vinToUse = originalVin || d1.vin || d2.vehicle_descriptor || '';
    const vinValid = vinToUse.length === 17;

    // Build engine description from vin-data-2 fields
    const engine = buildEngineDescription(d2);

    // modelYear from vin-data-1 is [startYear, endYear]; use start year unless vin-data-2 is more specific
    const year = parseYear(d2.model_year) ||
        (Array.isArray(d1.modelYear) && d1.modelYear.length > 0 ? d1.modelYear[0] : null);

    return {
        // Core identification
        vin: vinToUse,
        vinValid,

        // Basic vehicle information
        make: d2.make || d1.manufacturer || 'Unknown',
        model: d2.model || null,
        year,
        trim: d2.series || null,

        // Technical specifications
        engine,
        bodyType: d2.body_class || d2.vehicle_type || null,
        transmission: d2.transmission_style || null,
        drivetrain: null,

        // Manufacturer information
        manufacturer: d2.manufacturer_name || manuInfo.Manufacturer || d1.manufacturer || 'Unknown',
        origin: manuInfo.Country || d1.country || determineOrigin(d2.make || d1.manufacturer),

        // VIN metadata
        wmi: d1.wmi || vinToUse.substring(0, 3) || '',
        checksum: d2.error_text ? d2.error_text.startsWith('0') : null,

        // Additional vehicle details
        style: d2.series || null,
        doors: parseInteger(d2.doors),
        seats: null,
        fuelType: d2['fuel_type_-_primary'] || null,
        displacement: parseFloat(d2['displacement_(cc)']) || null,
        cylinders: parseInteger(d2.engine_number_of_cylinders),
        horsepower: parseFloat(d2.engine_brake_hp_from || d2['engine_brake_(hp)_from']) || null,
        torque: null,

        // Physical specifications
        length: null,
        width: null,
        height: null,
        wheelbase: null,
        weight: null,

        // Location data
        plantCity: d2.plant_city || null,
        plantCountry: d2.plant_country || null,

        // Source attribution
        _source: 'tecdoc-decoder-v5',

        // Raw content payloads for debugging (only in development)
        _raw: process.env.NODE_ENV === 'development'
            ? { d1, d2, d3: d3Array }
            : undefined,
    };
}

/**
 * Build engine description string from vin-data-2 fields.
 */
function buildEngineDescription(d2) {
    const components = [];

    const dispL = parseFloat(d2['displacement_(l)']);
    if (dispL > 0) components.push(`${dispL.toFixed(1)}L`);

    const cylinders = parseInteger(d2.engine_number_of_cylinders);
    if (cylinders > 0) components.push(`${cylinders}-cylinder`);

    const fuel = (d2['fuel_type_-_primary'] || '').toLowerCase();
    if (fuel.includes('diesel')) components.push('diesel');
    else if (fuel.includes('gasoline') || fuel.includes('petrol')) components.push('gasoline');
    else if (fuel.includes('electric')) components.push('electric');
    else if (fuel.includes('hybrid')) components.push('hybrid');

    const hp = parseFloat(d2.engine_brake_hp_from || d2['engine_brake_(hp)_from']);
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