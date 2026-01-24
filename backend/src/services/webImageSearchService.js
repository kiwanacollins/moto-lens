/**
 * Web Image Search Service
 * 
 * Searches the entire web for vehicle and spare parts images using
 * SerpApi, Bing Image Search, and Google Custom Search APIs.
 * 
 * Replaces AI image generation with real photos from the web.
 */

import axios from 'axios';

// API configuration
const SERPAPI_BASE_URL = 'https://serpapi.com/search';
const BING_IMAGE_URL = 'https://api.bing.microsoft.com/v7.0/images/search';
const GOOGLE_CUSTOM_SEARCH_URL = 'https://www.googleapis.com/customsearch/v1';

// Helper function to get API keys
function getApiKeys() {
    return {
        serpApi: process.env.SERPAPI_KEY,
        bingApi: process.env.BING_IMAGE_SEARCH_KEY,
        googleApi: process.env.GOOGLE_CUSTOM_SEARCH_KEY,
        googleCx: process.env.GOOGLE_CUSTOM_SEARCH_CX
    };
}

// Rate limiting: delay between requests
const REQUEST_DELAY_MS = 1000; // 1 second between requests
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// In-memory cache for search results (MVP)
const searchCache = new Map();
const CACHE_TTL = 6 * 60 * 60 * 1000; // 6 hours

/**
 * Search for vehicle images using web search APIs
 * @param {Object} vehicleData - Vehicle data from VIN decode
 * @returns {Promise<Object>} Search results with images
 */
export async function searchVehicleImages(vehicleData) {
    const { make, model, year, trim } = vehicleData;

    // Create cache key
    const cacheKey = `vehicle_${year}_${make}_${model}_${trim || 'standard'}`.toLowerCase().replace(/\s+/g, '_');

    // Check cache first
    const cached = searchCache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
        console.log(`Cache hit for vehicle search: ${cacheKey}`);
        return cached.data;
    }

    try {
        console.log(`Searching web for: ${year} ${make} ${model} ${trim || ''}`);

        // Create multiple search queries for better coverage
        const searchQueries = [
            `${year} ${make} ${model} ${trim || ''} car exterior`.trim(),
            `${year} ${make} ${model} front view`.trim(),
            `${year} ${make} ${model} side view`.trim(),
            `${year} ${make} ${model} rear view`.trim(),
            `${make} ${model} ${year} automotive photography`.trim()
        ];

        const allImages = [];

        // Search with each query using different APIs
        for (let i = 0; i < searchQueries.length; i++) {
            const query = searchQueries[i];

            try {
                // Add delay between requests
                if (i > 0) {
                    await sleep(REQUEST_DELAY_MS);
                }

                // Try SerpApi first (best results)
                const serpResults = await searchWithSerpApi(query);
                allImages.push(...serpResults);

                // Add small delay
                await sleep(500);

                // Try Bing for additional coverage
                const bingResults = await searchWithBing(query);
                allImages.push(...bingResults);

            } catch (error) {
                console.error(`Search failed for query: ${query}`, error.message);
                continue;
            }

            // Limit total images to avoid excessive requests
            if (allImages.length >= 50) break;
        }

        // Process and filter results
        const processedImages = processSearchResults(allImages);

        // If no images found and no API keys configured, provide fallback demo images
        const finalImages = processedImages.length > 0 ? processedImages : generateFallbackImages({ make, model, year, trim });

        const response = {
            vehicleInfo: { make, model, year, trim },
            images: finalImages,
            searchedAt: new Date().toISOString(),
            totalResults: allImages.length,
            queries: searchQueries,
            source: finalImages.length > 0 && processedImages.length === 0 ? 'fallback-demo' : 'web-search'
        };

        // Cache successful results
        if (processedImages.length > 0) {
            searchCache.set(cacheKey, {
                data: response,
                timestamp: Date.now()
            });
            console.log(`Cached ${processedImages.length} images for ${cacheKey}`);
        }

        return response;

    } catch (error) {
        console.error('Error searching vehicle images:', error);
        throw new VehicleImageSearchError(
            error.message || 'Failed to search vehicle images',
            'IMAGE_SEARCH_FAILED',
            500
        );
    }
}

/**
 * Search for spare parts images
 * @param {string} partName - Name of the part to search for
 * @param {Object} vehicleData - Vehicle data for context
 * @returns {Promise<Array>} Array of part image results
 */
export async function searchPartImages(partName, vehicleData) {
    const { make, model, year } = vehicleData;

    // Create cache key
    const cacheKey = `part_${make}_${model}_${year}_${partName}`.toLowerCase().replace(/\s+/g, '_');

    // Check cache first
    const cached = searchCache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
        console.log(`Cache hit for part search: ${cacheKey}`);
        return cached.data;
    }

    try {
        console.log(`Searching for part: ${partName} for ${year} ${make} ${model}`);

        // Create part-specific search queries
        const partQueries = [
            `${make} ${model} ${year} ${partName} part`,
            `${make} ${partName} OEM part`,
            `${partName} for ${year} ${make} ${model}`,
            `genuine ${make} ${partName}`,
            `${make} ${model} ${partName} replacement part`
        ];

        const partImages = [];

        for (let i = 0; i < partQueries.length; i++) {
            const query = partQueries[i];

            try {
                if (i > 0) {
                    await sleep(REQUEST_DELAY_MS);
                }

                // Use Google Lens via SerpApi for visual part search
                const lensResults = await searchWithGoogleLens(query);
                partImages.push(...lensResults);

                await sleep(500);

                // Use regular image search as backup
                const imageResults = await searchWithSerpApi(query);
                partImages.push(...imageResults);

            } catch (error) {
                console.error(`Part search failed for query: ${query}`, error.message);
                continue;
            }

            if (partImages.length >= 20) break;
        }

        const processedResults = processSearchResults(partImages);

        const response = {
            partName,
            vehicleInfo: { make, model, year },
            images: processedResults,
            searchedAt: new Date().toISOString(),
            queries: partQueries
        };

        // Cache results
        if (processedResults.length > 0) {
            searchCache.set(cacheKey, {
                data: response,
                timestamp: Date.now()
            });
            console.log(`Cached ${processedResults.length} part images for ${cacheKey}`);
        }

        return response;

    } catch (error) {
        console.error('Error searching part images:', error);
        throw new PartImageSearchError(
            error.message || 'Failed to search part images',
            'PART_SEARCH_FAILED',
            500
        );
    }
}

/**
 * Search with SerpApi (Google Images)
 */
async function searchWithSerpApi(query) {
    const { serpApi } = getApiKeys();

    if (!serpApi) {
        console.log('SerpApi key not configured, skipping');
        return [];
    }

    try {
        const response = await axios.get(SERPAPI_BASE_URL, {
            params: {
                engine: 'google_images',
                q: query,
                num: 20,
                api_key: serpApi,
                ijn: 0 // First page
            },
            timeout: 15000
        });

        const results = response.data.images_results || [];

        return results.map(result => ({
            title: result.title || 'Untitled',
            url: result.original || result.link,
            thumbnail: result.thumbnail,
            source: result.source || 'google',
            width: result.original_width || 0,
            height: result.original_height || 0,
            searchEngine: 'serpapi-google'
        }));

    } catch (error) {
        console.error('SerpApi search failed:', error.message);
        return [];
    }
}

/**
 * Search with Google Lens via SerpApi
 */
async function searchWithGoogleLens(query) {
    const { serpApi } = getApiKeys();

    if (!serpApi) {
        return [];
    }

    try {
        const response = await axios.get(SERPAPI_BASE_URL, {
            params: {
                engine: 'google_lens',
                q: query,
                api_key: serpApi
            },
            timeout: 15000
        });

        const visualMatches = response.data.visual_matches || [];

        return visualMatches.map(match => ({
            title: match.title || 'Visual Match',
            url: match.link,
            thumbnail: match.thumbnail,
            source: match.source || 'google-lens',
            width: 0,
            height: 0,
            searchEngine: 'google-lens'
        }));

    } catch (error) {
        console.error('Google Lens search failed:', error.message);
        return [];
    }
}

/**
 * Search with Bing Image Search API
 */
async function searchWithBing(query) {
    const { bingApi } = getApiKeys();

    if (!bingApi) {
        console.log('Bing API key not configured, skipping');
        return [];
    }

    try {
        const response = await axios.get(BING_IMAGE_URL, {
            params: {
                q: query,
                count: 20,
                imageType: 'Photo',
                size: 'Large',
                freshness: 'Month' // Prefer recent images
            },
            headers: {
                'Ocp-Apim-Subscription-Key': bingApi
            },
            timeout: 15000
        });

        const results = response.data.value || [];

        return results.map(result => ({
            title: result.name || 'Untitled',
            url: result.contentUrl,
            thumbnail: result.thumbnailUrl,
            source: result.hostPageDisplayUrl || 'bing',
            width: result.width || 0,
            height: result.height || 0,
            searchEngine: 'bing'
        }));

    } catch (error) {
        console.error('Bing search failed:', error.message);
        return [];
    }
}

/**
 * Process and filter search results
 */
function processSearchResults(results) {
    // Remove duplicates based on URL
    const uniqueResults = results.filter((result, index, array) =>
        array.findIndex(r => r.url === result.url) === index
    );

    // Filter by quality criteria
    const qualityFiltered = uniqueResults.filter(result => {
        // Skip if no URL
        if (!result.url) return false;

        // Skip very small images (likely thumbnails or icons)
        if (result.width > 0 && result.height > 0) {
            if (result.width < 400 || result.height < 300) return false;
        }

        // Skip if title suggests it's not a car image
        const title = (result.title || '').toLowerCase();
        const badKeywords = ['logo', 'icon', 'diagram', 'chart', 'text', 'screenshot'];
        if (badKeywords.some(keyword => title.includes(keyword))) return false;

        return true;
    });

    // Sort by quality indicators
    const sorted = qualityFiltered.sort((a, b) => {
        // Prefer larger images
        const aSize = (a.width || 0) * (a.height || 0);
        const bSize = (b.width || 0) * (b.height || 0);

        if (aSize !== bSize) {
            return bSize - aSize;
        }

        // Prefer certain sources
        const preferredSources = ['google', 'bing'];
        const aPreferred = preferredSources.includes(a.searchEngine);
        const bPreferred = preferredSources.includes(b.searchEngine);

        if (aPreferred !== bPreferred) {
            return bPreferred ? 1 : -1;
        }

        return 0;
    });

    // Return top 8 results mapped to MotoLens format
    const angles = ['front', 'front-left', 'left', 'rear-left', 'rear', 'rear-right', 'right', 'front-right'];

    return sorted.slice(0, 8).map((result, index) => ({
        angle: angles[index] || 'front',
        imageUrl: result.url,
        thumbnail: result.thumbnail,
        title: result.title,
        source: result.source,
        searchEngine: result.searchEngine,
        imageData: null, // Not base64, using URLs
        isBase64: false,
        success: true,
        error: null,
        model: 'web-search',
        width: result.width,
        height: result.height
    }));
}

/**
 * Custom error classes
 */
class VehicleImageSearchError extends Error {
    constructor(message, code, status) {
        super(message);
        this.name = 'VehicleImageSearchError';
        this.code = code;
        this.status = status;
    }
}

class PartImageSearchError extends Error {
    constructor(message, code, status) {
        super(message);
        this.name = 'PartImageSearchError';
        this.code = code;
        this.status = status;
    }
}

/**
 * Generate fallback demo images when no API keys are configured
 * @param {Object} vehicleData - Vehicle data
 * @returns {Array} Demo images for testing
 */
function generateFallbackImages(vehicleData) {
    const { make, model, year } = vehicleData;
    const angles = ['front', 'front-left', 'left', 'rear-left', 'rear', 'rear-right', 'right', 'front-right'];

    console.log(`Generating fallback demo images for ${year} ${make} ${model}`);

    // Use high-quality placeholder images that look like actual cars
    const baseUrl = 'https://via.placeholder.com/800x600';
    const makeColors = {
        'BMW': '1e3a8a', // Blue
        'Audi': 'd1d5db', // Silver  
        'Mercedes-Benz': '111827', // Black
        'Volkswagen': '0ea5e9', // Electric Blue (MotoLens brand color)
        'Porsche': 'dc2626', // Red
    };

    const color = makeColors[make] || '6b7280'; // Default gray

    return angles.map((angle, index) => ({
        angle,
        imageUrl: `${baseUrl}/${color}/ffffff?text=${encodeURIComponent(`${year} ${make} ${model} - ${angle.replace('-', ' ')}`)}`,
        thumbnail: `https://via.placeholder.com/200x150/${color}/ffffff?text=${angle}`,
        title: `${year} ${make} ${model} - ${angle.replace('-', ' ')} view`,
        source: 'fallback-demo',
        searchEngine: 'placeholder',
        imageData: null,
        isBase64: false,
        success: true,
        error: null,
        model: 'fallback-demo',
        width: 800,
        height: 600,
        generatedAt: new Date().toISOString()
    }));
}

/**
 * Clear cache function for maintenance
 */
export function clearSearchCache() {
    searchCache.clear();
    console.log('Search cache cleared');
}

/**
 * Get cache statistics
 */
export function getCacheStats() {
    return {
        size: searchCache.size,
        keys: Array.from(searchCache.keys())
    };
}