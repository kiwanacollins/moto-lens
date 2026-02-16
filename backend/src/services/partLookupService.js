/**
 * Part Lookup Service — SerpAPI Google Search
 * 
 * Looks up automotive part details via SerpAPI (Google Search).
 * Returns structured results with part name, description, image, and web links.
 * If nothing is found, returns null (caller should respond "data not found").
 * Gemini AI is NOT used here — only real web data.
 */

import axios from 'axios';

// ─────────────────────────────────────────────────────────────────────────────
// SerpAPI Google Search
// ─────────────────────────────────────────────────────────────────────────────

async function lookupViaSerpApi(partNumber, vehicleData) {
    const serpApiKey = process.env.SERPAPI_KEY;
    if (!serpApiKey) {
        console.log('🔎 SerpAPI key not configured');
        return null;
    }

    const vehicleContext = vehicleData
        ? `${vehicleData.year || ''} ${vehicleData.make || ''} ${vehicleData.model || ''}`.trim()
        : '';

    const webQuery = vehicleContext
        ? `"${partNumber}" ${vehicleContext} auto part`
        : `"${partNumber}" automotive part OEM specifications`;

    const imageQuery = vehicleContext
        ? `${partNumber} ${vehicleContext} auto part`
        : `${partNumber} automotive part`;

    try {
        console.log(`🔎 SerpAPI: searching "${webQuery}"`);

        // Run web search + image search in parallel for speed
        const [webResponse, imageResponse] = await Promise.all([
            axios.get('https://serpapi.com/search', {
                params: {
                    engine: 'google',
                    q: webQuery,
                    api_key: serpApiKey,
                    num: 5
                },
                timeout: 10000
            }),
            axios.get('https://serpapi.com/search', {
                params: {
                    engine: 'google_images',
                    q: imageQuery,
                    api_key: serpApiKey,
                    num: 3,
                    safe: 'active'
                },
                timeout: 10000
            }).catch(err => {
                console.error('🖼️ Image search error:', err.message);
                return null;
            })
        ]);

        const results = webResponse.data;
        const organicResults = results.organic_results || [];

        if (organicResults.length === 0) {
            return null;
        }

        // Collect snippets from top results
        const topResult = organicResults[0];
        const descriptionParts = organicResults.slice(0, 3)
            .map(r => r.snippet)
            .filter(Boolean);

        // Try to extract a meaningful part name from the top title
        const partName = extractPartName(topResult.title, partNumber);

        // Get image: prefer Google Images results, fall back to shopping thumbnails
        let imageUrl = null;
        if (imageResponse?.data) {
            const imageResults = imageResponse.data.images_results || [];
            if (imageResults.length > 0) {
                imageUrl = imageResults[0].original || imageResults[0].thumbnail;
                console.log(`🖼️ Found part image from Google Images`);
            }
        }
        if (!imageUrl) {
            const shoppingResults = results.shopping_results || [];
            if (shoppingResults.length > 0 && shoppingResults[0].thumbnail) {
                imageUrl = shoppingResults[0].thumbnail;
                console.log(`🖼️ Found part image from shopping results`);
            }
        }

        return {
            source: 'google-search',
            partName: partName || partNumber,
            partNumber,
            supplier: null,
            imageUrl,
            description: descriptionParts.join(' ') || `Search results for part ${partNumber}`,
            searchResults: organicResults.slice(0, 5).map(r => ({
                title: r.title,
                snippet: r.snippet,
                link: r.link
            }))
        };
    } catch (error) {
        console.error('🔎 SerpAPI search error:', error.message);
        return null;
    }
}

/**
 * Try to extract a clean part name from a search result title.
 */
function extractPartName(title, partNumber) {
    if (!title) return null;

    // Remove the part number itself first
    const escaped = partNumber.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    let name = title.replace(new RegExp(escaped, 'gi'), '');

    // Split on common delimiters and pick the longest meaningful segment
    const segments = name
        .split(/[|–—]/)
        .map(s => s.replace(/[-]/g, ' ').replace(/\s+/g, ' ').trim())
        .filter(s => s.length > 3);

    if (segments.length > 0) {
        // Prefer a segment that doesn't start with a year
        const best = segments.find(s => !/^\d{4}\b/.test(s)) || segments[0];
        return best;
    }

    return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Public API
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Look up a part by number using SerpAPI Google Search.
 * 
 * @param {string} partNumber - The part/article/OEM number to look up
 * @param {Object|null} vehicleData - Optional vehicle context { make, model, year }
 * @returns {Promise<Object|null>} Part details or null if not found
 */
export async function lookupPart(partNumber, vehicleData = null) {
    if (!partNumber || typeof partNumber !== 'string' || partNumber.trim().length === 0) {
        return null;
    }

    const cleaned = partNumber.trim();
    console.log(`🔍 Part lookup: "${cleaned}"`);

    const result = await lookupViaSerpApi(cleaned, vehicleData);
    if (result) {
        console.log('  ✅ Found via SerpAPI');
        return result;
    }

    console.log('  ❌ Part not found');
    return null;
}

export default { lookupPart };
