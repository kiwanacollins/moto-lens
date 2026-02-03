/**
 * Multi-Provider VIN Service
 * 
 * Robust VIN decoding with multiple API providers and intelligent fallback
 * Primary: Zyla Labs VIN Decode API
 * Fallback: NHTSA vPIC (free, government-backed)
 * Secondary Fallback: Vincario (European specialist, paid)
 * Enhancement: Gemini AI for missing data
 */

import zylaVinService from './zylaVinService.js';
import nhtsaVinService from './nhtsaVinService.js';
import vincarioVinService from './vincarioVinService.js';

/**
 * VIN decoding strategy configuration
 */
const PROVIDERS = {
    ZYLA: 'zyla',
    NHTSA: 'nhtsa',
    VINCARIO: 'vincario'
};

const STRATEGY_CONFIG = {
    // Try Zyla Labs first (primary), fallback to NHTSA (free), then Vincario if needed
    providers: [PROVIDERS.ZYLA, PROVIDERS.NHTSA, PROVIDERS.VINCARIO],

    // Conditions for trying fallback provider
    fallbackConditions: {
        // Try next provider if VIN is invalid
        invalidVin: true,
        // Try next provider if critical data is missing
        missingCriticalData: true,
        // Try next provider if API error occurs
        apiError: true
    },

    // Critical fields that must be present for a successful decode
    criticalFields: ['make', 'year'],

    // Important fields that should trigger fallback if missing
    importantFields: ['model', 'bodyType', 'engine']
};

/**
 * Decode VIN using multi-provider strategy
 * @param {string} vin - 17-character Vehicle Identification Number
 * @returns {Promise<Object>} Decoded vehicle data
 */
export async function decodeVIN(vin) {
    const errors = [];
    let bestResult = null;
    let bestScore = 0;

    for (const provider of STRATEGY_CONFIG.providers) {
        try {
            console.log(`🔍 Trying VIN decode with ${provider.toUpperCase()}...`);

            let result;
            let parsedResult;

            switch (provider) {
                case PROVIDERS.ZYLA:
                    result = await zylaVinService.decodeVIN(vin);
                    parsedResult = zylaVinService.parseVehicleData(result, vin);
                    break;

                case PROVIDERS.NHTSA:
                    result = await nhtsaVinService.decodeVIN(vin);
                    // Pass original VIN to preserve it (NHTSA returns modified VIN with ! for errors)
                    parsedResult = nhtsaVinService.parseVehicleData(result, vin);
                    break;

                case PROVIDERS.VINCARIO:
                    // Only try Vincario if API key is configured
                    if (!process.env.VINCARIO_API_KEY) {
                        console.log(`⏭️ Skipping ${provider} - API key not configured`);
                        continue;
                    }
                    result = await vincarioVinService.decodeVIN(vin);
                    parsedResult = vincarioVinService.parseVehicleData(result, vin);
                    break;

                default:
                    continue;
            }

            // Score the result quality
            const score = scoreVehicleData(parsedResult);
            console.log(`📊 ${provider.toUpperCase()} result score: ${score}/100`);

            // Keep track of best result
            if (score > bestScore) {
                bestResult = parsedResult;
                bestScore = score;
            }

            // If result is good enough, use it
            if (score >= 70) {
                console.log(`✅ Using ${provider.toUpperCase()} result (score: ${score}/100)`);
                return bestResult;
            }

        } catch (error) {
            console.log(`❌ ${provider.toUpperCase()} failed: ${error.message}`);
            errors.push({
                provider,
                error: error.message,
                code: error.code || 'UNKNOWN_ERROR'
            });

            // Continue to next provider unless it's a VIN format error
            if (error.code === 'INVALID_VIN_FORMAT') {
                break;
            }
        }
    }

    // If we have any result, return the best one
    if (bestResult) {
        console.log(`🎯 Using best available result (score: ${bestScore}/100)`);
        return bestResult;
    }

    // All providers failed
    const primaryError = errors.find(e => e.provider === PROVIDERS.ZYLA) || errors[0];
    throw new VINDecodeError(
        `All VIN providers failed. Primary error: ${primaryError?.error || 'Unknown error'}`,
        primaryError?.code || 'ALL_PROVIDERS_FAILED',
        500
    );
}

/**
 * Parse vehicle data using the original auto.dev format for compatibility
 * @param {Object} vehicleData - Decoded vehicle data from any provider
 * @returns {Object} Vehicle data in auto.dev compatible format
 */
export function parseVehicleData(vehicleData) {
    // Data is already parsed by individual provider services
    // This function maintains compatibility with existing code
    return vehicleData;
}

/**
 * Score vehicle data quality (0-100)
 * @param {Object} vehicleData - Parsed vehicle data
 * @returns {number} Quality score
 */
function scoreVehicleData(vehicleData) {
    let score = 0;

    // Critical fields (40 points total)
    if (vehicleData.make && vehicleData.make !== 'Unknown') score += 20;
    if (vehicleData.year && vehicleData.year > 1980) score += 20;

    // Important fields (30 points total)
    if (vehicleData.model && vehicleData.model !== null) score += 15;
    if (vehicleData.bodyType && vehicleData.bodyType !== null) score += 8;
    if (vehicleData.engine && vehicleData.engine !== null) score += 7;

    // Useful fields (20 points total)
    if (vehicleData.manufacturer && vehicleData.manufacturer !== 'Unknown') score += 5;
    if (vehicleData.trim && vehicleData.trim !== null) score += 5;
    if (vehicleData.transmission && vehicleData.transmission !== null) score += 5;
    if (vehicleData.drivetrain && vehicleData.drivetrain !== null) score += 5;

    // Bonus points (10 points total)
    if (vehicleData.vinValid === true) score += 5;
    if (vehicleData.displacement && vehicleData.displacement > 0) score += 3;
    if (vehicleData.cylinders && vehicleData.cylinders > 0) score += 2;

    return Math.min(score, 100);
}

/**
 * Check if vehicle data has critical missing information
 * @param {Object} vehicleData - Parsed vehicle data
 * @returns {boolean} True if critical data is missing
 */
function hasMissingCriticalData(vehicleData) {
    return STRATEGY_CONFIG.criticalFields.some(field => {
        const value = vehicleData[field];
        return !value || value === 'Unknown' || value === 'Not specified';
    });
}

/**
 * Check if vehicle data has missing important information
 * @param {Object} vehicleData - Parsed vehicle data
 * @returns {boolean} True if important data is missing
 */
function hasMissingImportantData(vehicleData) {
    const missingCount = STRATEGY_CONFIG.importantFields.filter(field => {
        const value = vehicleData[field];
        return !value || value === 'Unknown' || value === 'Not specified';
    }).length;

    // Consider important data missing if more than half of important fields are empty
    return missingCount > STRATEGY_CONFIG.importantFields.length / 2;
}

/**
 * Custom error class for multi-provider VIN decode errors
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