/**
 * Web Image Search Service - FAST SerpApi Only
 * 
 * Optimized for speed: Single SerpApi request, no delays.
 * Returns real photos from Google Images in ~2-3 seconds.
 */

import axios from 'axios';

// API configuration
const SERPAPI_BASE_URL = 'https://serpapi.com/search';

// In-memory cache for search results (MVP)
const searchCache = new Map();
const CACHE_TTL = 24 * 60 * 60 * 1000; // 24 hours cache

/**
 * Search for vehicle images using SerpApi (FAST - single request)
 * @param {Object} vehicleData - Vehicle data from VIN decode
 * @returns {Promise<Object>} Search results with images
 */
export async function searchVehicleImages(vehicleData) {
    const { make, model, year, trim } = vehicleData;

    // Create cache key
    const cacheKey = `vehicle_${year}_${make}_${model}`.toLowerCase().replace(/\s+/g, '_');

    // Check cache first (instant response if cached)
    // TEMPORARILY DISABLED: Force fresh image searches
    const cached = null; // searchCache.get(cacheKey);
    
    /* Original cache logic (re-enable later)
    const cached = searchCache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
        console.log(`⚡ Cache hit: ${cacheKey}`);
        return cached.data;
    }
    */

    const serpApiKey = process.env.SERPAPI_KEY;

    // If no API key, return fallback immediately
    if (!serpApiKey) {
        console.log('⚠️ SerpApi key not configured, using fallback images');
        return createFallbackResponse(vehicleData);
    }

    try {
        const startTime = Date.now();
        console.log(`🔍 SerpApi search: ${year} ${make} ${model}`);

        // Single optimized search query
        const searchQuery = `${year} ${make} ${model} car photo exterior`;

        const response = await axios.get(SERPAPI_BASE_URL, {
            params: {
                engine: 'google_images',
                q: searchQuery,
                num: 6, // Reduced from 10 for faster response
                api_key: serpApiKey,
                ijn: 0,
                safe: 'active',
                tbm: 'isch',
                tbs: 'isz:m', // Medium images (faster to load than large)
                no_cache: false
            },
            timeout: 6000 // Reduced from 8 seconds
        });

        const results = response.data.images_results || [];
        const elapsed = Date.now() - startTime;
        console.log(`✅ SerpApi returned ${results.length} images in ${elapsed}ms`);

        // Log first result to debug watermark issue
        if (results.length > 0) {
            console.log('📸 First image URL:', results[0].original || results[0].link);
            console.log('📸 First thumbnail URL:', results[0].thumbnail);
        }

        // Process results into German Car Medic format - limit to 5 images for speed
        const images = results.slice(0, 5).map((result, index) => ({
            angle: getAngle(index),
            imageUrl: result.original || result.link,
            thumbnail: result.thumbnail,
            title: result.title || `${year} ${make} ${model}`,
            source: result.source || 'google',
            searchEngine: 'serpapi',
            width: result.original_width || 800,
            height: result.original_height || 600,
            success: true,
            model: `${year} ${make} ${model}`,
            isBase64: false,
            error: null
        }));

        // Use fallback if no results
        const finalImages = images.length > 0 ? images : generateFallbackImages(vehicleData);

        const responseData = {
            vehicleInfo: { make, model, year, trim },
            images: finalImages,
            searchedAt: new Date().toISOString(),
            totalResults: results.length,
            source: images.length > 0 ? 'serpapi' : 'fallback',
            latencyMs: elapsed
        };

        // Cache the results
        searchCache.set(cacheKey, { data: responseData, timestamp: Date.now() });
        console.log(`💾 Cached ${finalImages.length} images for ${cacheKey}`);

        return responseData;

    } catch (error) {
        console.error('❌ SerpApi error:', error.message);
        return createFallbackResponse(vehicleData, error.message);
    }
}

/**
 * Search for spare parts images (fast single request)
 */
export async function searchPartImages(partName, vehicleData = {}) {
    // Handle missing or incomplete vehicle data gracefully
    const make = vehicleData?.make || 'automotive';
    const model = vehicleData?.model || '';
    const year = vehicleData?.year || '';

    const cacheKey = `part_${make}_${model}_${partName}`.toLowerCase().replace(/\s+/g, '_');

    // Check cache
    const cached = searchCache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
        console.log(`⚡ Part cache hit: ${cacheKey}`);
        return cached.data;
    }

    const serpApiKey = process.env.SERPAPI_KEY;

    if (!serpApiKey) {
        console.warn('⚠️ No SERPAPI_KEY configured');
        return { partName, images: [], source: 'no-api-key' };
    }

    try {
        // Build search query with available context
        const searchTerms = [make, model, partName, 'auto part'].filter(Boolean).join(' ');
        console.log(`🔍 SerpApi part search: "${searchTerms}"`);

        const response = await axios.get(SERPAPI_BASE_URL, {
            params: {
                engine: 'google_images',
                q: searchTerms,
                num: 8,
                api_key: serpApiKey,
                safe: 'active'
            },
            timeout: 8000
        });

        const results = response.data.images_results || [];

        const images = results.slice(0, 5).map(result => ({
            imageUrl: result.original || result.link,
            thumbnail: result.thumbnail,
            title: result.title || partName,
            source: result.source || 'google',
            success: true
        }));

        const responseData = {
            partName,
            vehicleInfo: { make, model, year },
            images,
            searchedAt: new Date().toISOString(),
            source: 'serpapi'
        };

        searchCache.set(cacheKey, { data: responseData, timestamp: Date.now() });
        return responseData;

    } catch (error) {
        console.error('❌ Part search error:', error.message);
        return { partName, images: [], source: 'error', error: error.message };
    }
}

/**
 * Get angle name from index
 */
function getAngle(index) {
    const angles = ['front', 'front-right', 'right', 'rear-right', 'rear', 'rear-left', 'left', 'front-left'];
    return angles[index % angles.length];
}

/**
 * Create fallback response with demo images
 */
function createFallbackResponse(vehicleData, errorMessage = null) {
    return {
        vehicleInfo: vehicleData,
        images: generateFallbackImages(vehicleData),
        searchedAt: new Date().toISOString(),
        totalResults: 8,
        source: 'fallback',
        error: errorMessage
    };
}

/**
 * Generate fallback demo images
 */
function generateFallbackImages(vehicleData) {
    const { make, model, year } = vehicleData;
    const angles = ['front', 'front-right', 'right', 'rear-right', 'rear', 'rear-left', 'left', 'front-left'];

    // Brand colors for placeholders
    const colors = {
        'BMW': '1e3a8a',
        'Audi': 'd1d5db',
        'Mercedes-Benz': '111827',
        'Volkswagen': '0ea5e9',
        'Porsche': 'dc2626'
    };

    const color = colors[make] || '6b7280';

    return angles.map((angle, index) => ({
        angle,
        imageUrl: `https://placehold.co/800x600/${color}/ffffff?text=${encodeURIComponent(`${make} ${model}`)}`,
        thumbnail: `https://placehold.co/200x150/${color}/ffffff?text=${angle}`,
        title: `${year} ${make} ${model} - ${angle}`,
        source: 'placeholder',
        searchEngine: 'fallback',
        width: 800,
        height: 600,
        success: true,
        model: 'fallback',
        isBase64: false,
        error: null
    }));
}

/**
 * Clear the search cache
 */
export function clearSearchCache() {
    searchCache.clear();
    console.log('🗑️ Search cache cleared');
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
