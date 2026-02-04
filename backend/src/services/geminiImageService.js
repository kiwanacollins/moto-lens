/**
 * Google Gemini Image Generation Service
 * 
 * Generates photorealistic vehicle images using Google Generative AI
 * with Gemini's native image generation capabilities via AI Studio API.
 */

import axios from 'axios';

// Google Generative AI API configuration  
const GEMINI_API_BASE_URL = 'https://generativelanguage.googleapis.com/v1beta/models';

// Model for image generation - Imagen 4 (available in your account)
const IMAGE_MODEL = 'imagen-4.0-generate-001';

// Helper function to get API key (ensures env is loaded)
function getApiKey() {
    const key = process.env.GEMINI_API_KEY;
    if (!key) {
        throw new Error('GEMINI_API_KEY is not configured in environment');
    }
    return key;
}

// Rate limiting: delay between requests to avoid 429 errors
const REQUEST_DELAY_MS = 2000; // 2 seconds between requests
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Vehicle image generation angles
const IMAGE_ANGLES = [
    'front',
    'front-left',
    'left',
    'rear-left',
    'rear',
    'rear-right',
    'right',
    'front-right'
];

// In-memory cache for generated images (MVP)
const imageCache = new Map();
const CACHE_TTL = 24 * 60 * 60 * 1000; // 24 hours

/**
 * Generate vehicle images for all angles
 * @param {Object} vehicleData - Vehicle data from VIN decode
 * @returns {Promise<Object>} Generated images data
 */
export async function generateVehicleImages(vehicleData) {
    const { make, model, year, trim } = vehicleData;

    // Create cache key
    const cacheKey = `${year}_${make}_${model}_${trim || 'standard'}`.toLowerCase().replace(/\s+/g, '_');

    // Check cache first
    // TEMPORARILY DISABLED: Force fresh image generation
    const cached = null; // imageCache.get(cacheKey);

    /* Original cache logic (re-enable later)
    const cached = imageCache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
        console.log(`Cache hit for ${cacheKey}`);
        return cached.data;
    }
    */

    try {
        console.log(`Generating images for: ${year} ${make} ${model} ${trim || ''}`);

        // Generate images for each angle sequentially with delay to avoid rate limiting
        const images = {};

        for (let i = 0; i < IMAGE_ANGLES.length; i++) {
            const angle = IMAGE_ANGLES[i];

            // Add delay between requests to avoid rate limiting
            if (i > 0) {
                await sleep(REQUEST_DELAY_MS);
            }

            const result = await generateSingleImage(vehicleData, angle);
            images[angle] = result;
        }

        const response = {
            vehicleInfo: {
                make,
                model,
                year,
                trim
            },
            images,
            generatedAt: new Date().toISOString(),
            angles: IMAGE_ANGLES
        };

        // Cache successful results
        if (Object.values(images).some(img => img.success)) {
            imageCache.set(cacheKey, {
                data: response,
                timestamp: Date.now()
            });
            console.log(`Cached images for ${cacheKey}`);
        }

        return response;

    } catch (error) {
        console.error('Error generating vehicle images:', error);
        throw new VehicleImageError(
            error.message || 'Failed to generate vehicle images',
            'IMAGE_GENERATION_FAILED',
            500
        );
    }
}

/**
 * Generate a single vehicle image for specific angle
 * @param {Object} vehicleData - Vehicle data
 * @param {string} angle - Image angle (front, left, etc.)
 * @returns {Promise<Object>} Generated image data
 */
async function generateSingleImage(vehicleData, angle) {
    const { make, model, year, trim } = vehicleData;

    // Create detailed prompt
    const vehicleDescription = trim ? `${year} ${make} ${model} ${trim}` : `${year} ${make} ${model}`;
    const prompt = createImagePrompt(vehicleDescription, angle);

    try {
        console.log(`Generating ${angle} image for: ${vehicleDescription}`);

        const apiKey = getApiKey();

        // Use Imagen 4 API endpoint for image generation
        const response = await axios.post(
            `${GEMINI_API_BASE_URL}/${IMAGE_MODEL}:predict?key=${apiKey}`,
            {
                instances: [{
                    prompt: prompt
                }],
                parameters: {
                    sampleCount: 1,
                    aspectRatio: "16:9",
                    safetyFilterLevel: "block_only_high",
                    personGeneration: "dont_allow"
                }
            },
            {
                headers: {
                    'Content-Type': 'application/json'
                },
                timeout: 120000 // 120 second timeout for image generation
            }
        );

        // Parse the Imagen response
        const responseData = response.data;

        // Imagen returns predictions array with bytesBase64Encoded
        if (responseData.predictions?.[0]?.bytesBase64Encoded) {
            const base64Image = responseData.predictions[0].bytesBase64Encoded;
            const mimeType = responseData.predictions[0].mimeType || 'image/png';

            return {
                success: true,
                angle,
                imageData: base64Image,
                imageUrl: `data:${mimeType};base64,${base64Image}`,
                mimeType,
                prompt,
                generatedAt: new Date().toISOString(),
                fileSize: Math.round(base64Image.length * 0.75),
                model: IMAGE_MODEL
            };
        }

        // If no image was generated, throw error to fall back to mock
        throw new Error('No image data in API response');

    } catch (error) {
        console.error(`Error generating ${angle} image:`, error.message);

        // Fallback: use mock image for development
        if (process.env.NODE_ENV === 'development' || process.env.USE_MOCK_IMAGES === 'true') {
            return generateMockImage(vehicleData, angle, prompt);
        }

        // Return a structured error response
        return {
            success: false,
            angle,
            error: `Failed to generate ${angle} image: ${error.message}`,
            prompt,
            generatedAt: new Date().toISOString(),
            details: error.response?.data || error.message
        };
    }
}/**
 * Generate mock image for development/fallback
 * @param {Object} vehicleData - Vehicle data
 * @param {string} angle - Image angle
 * @param {string} prompt - Original prompt
 * @returns {Object} Mock image response
 */
function generateMockImage(vehicleData, angle, prompt) {
    const { make, model, year } = vehicleData;

    // Generate a placeholder image URL using a service like picsum or via.placeholder
    const mockImageUrl = `https://via.placeholder.com/1024x576/1e293b/0ea5e9?text=${encodeURIComponent(`${year} ${make} ${model}`)}+${angle.replace('-', ' ')}`;

    // Create a simple base64 encoded placeholder (1x1 transparent pixel)
    const placeholderBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==';

    return {
        success: true,
        angle,
        imageData: placeholderBase64,
        imageUrl: mockImageUrl,
        mimeType: 'image/png',
        prompt,
        generatedAt: new Date().toISOString(),
        isMock: true,
        fileSize: 125, // Size of the placeholder
        note: 'Development/fallback mock image'
    };
}

/**
 * Create optimized image prompt for vehicle photography
 * @param {string} vehicleDescription - Full vehicle description
 * @param {string} angle - Image angle
 * @returns {string} Optimized prompt
 */
function createImagePrompt(vehicleDescription, angle) {
    const basePrompt = `
Photorealistic studio image of a ${vehicleDescription},
${angle} view,
neutral white background,
professional automotive photography,
studio lighting with soft shadows,
high detail and sharp focus,
clean and pristine condition,
centered in frame,
automotive showroom quality,
realistic materials and reflections,
no people or text overlays,
commercial product photography style
`.trim().replace(/\s+/g, ' ');

    // Add angle-specific details
    const angleModifiers = {
        'front': 'showing headlights, grille, and front bumper clearly',
        'front-left': 'three-quarter front view showing both front and side profile',
        'left': 'perfect side profile showing wheel wells and door handles',
        'rear-left': 'three-quarter rear view showing both rear and side elements',
        'rear': 'showing taillights, rear bumper, and exhaust clearly',
        'rear-right': 'three-quarter rear view from right side',
        'right': 'perfect side profile from passenger side',
        'front-right': 'three-quarter front view from passenger side'
    };

    const modifier = angleModifiers[angle] || '';
    return `${basePrompt}, ${modifier}`;
}

/**
 * Get cached image data
 * @param {string} cacheKey - Cache key
 * @returns {Object|null} Cached data or null
 */
export function getCachedImages(cacheKey) {
    const cached = imageCache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
        return cached.data;
    }
    return null;
}

/**
 * Clear expired cache entries
 */
export function cleanCache() {
    const now = Date.now();
    for (const [key, value] of imageCache.entries()) {
        if (now - value.timestamp >= CACHE_TTL) {
            imageCache.delete(key);
        }
    }
}

/**
 * Get cache statistics
 * @returns {Object} Cache stats
 */
export function getCacheStats() {
    const now = Date.now();
    const entries = Array.from(imageCache.entries());

    const validEntries = entries.filter(([_, value]) => now - value.timestamp < CACHE_TTL);
    const expiredEntries = entries.filter(([_, value]) => now - value.timestamp >= CACHE_TTL);

    return {
        total: imageCache.size,
        valid: validEntries.length,
        expired: expiredEntries.length,
        keys: validEntries.map(([key]) => key),
        expiredKeys: expiredEntries.map(([key]) => key),
        cacheTtlHours: CACHE_TTL / (60 * 60 * 1000),
        oldestEntry: entries.length > 0 ? Math.min(...entries.map(([_, v]) => v.timestamp)) : null,
        newestEntry: entries.length > 0 ? Math.max(...entries.map(([_, v]) => v.timestamp)) : null
    };
}

/**
 * Custom error class for vehicle image generation
 */
export class VehicleImageError extends Error {
    constructor(message, code, statusCode) {
        super(message);
        this.name = 'VehicleImageError';
        this.code = code;
        this.statusCode = statusCode;
    }
}

/**
 * Clear all cache entries
 */
export function clearAllCache() {
    const size = imageCache.size;
    imageCache.clear();
    console.log(`Cleared ${size} cached entries`);
    return { cleared: size, remaining: imageCache.size };
}

/**
 * Generate vehicle images with force refresh option
 * @param {Object} vehicleData - Vehicle data from VIN decode
 * @param {boolean} forceRefresh - Skip cache and generate new images
 * @returns {Promise<Object>} Generated images data
 */
export async function generateVehicleImagesWithOptions(vehicleData, options = {}) {
    const { forceRefresh = false } = options;

    if (forceRefresh) {
        const { make, model, year, trim } = vehicleData;
        const cacheKey = `${year}_${make}_${model}_${trim || 'standard'}`.toLowerCase().replace(/\s+/g, '_');
        imageCache.delete(cacheKey);
        console.log(`Force refresh: cleared cache for ${cacheKey}`);
    }

    return generateVehicleImages(vehicleData);
}

// Clean cache every hour
setInterval(cleanCache, 60 * 60 * 1000);

export default {
    generateVehicleImages,
    generateVehicleImagesWithOptions,
    getCachedImages,
    cleanCache,
    clearAllCache,
    getCacheStats,
    VehicleImageError
};