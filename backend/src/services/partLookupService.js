/**
 * Part Lookup Service — SerpAPI Google Search
 * 
 * Looks up automotive part details via SerpAPI (Google Search).
 * Returns structured results with part name, description, image, and web links.
 * If nothing is found, returns null (caller should respond "data not found").
 * Gemini AI is NOT used here — only real web data.
 */

import axios from 'axios';
import { extractPartNumber, extractBarcodeMetadata } from '../utils/barcodeParser.js';

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

    // Try multiple search queries with decreasing specificity
    const searchStrategies = [
        // Strategy 1: With vehicle context (most specific)
        vehicleContext
            ? `${partNumber} ${vehicleContext} auto part`
            : null,
        // Strategy 2: Part number + generic automotive terms
        `${partNumber} automotive part`,
        // Strategy 3: Part number + car part
        `${partNumber} car part`,
        // Strategy 4: Just the part number (least restrictive)
        partNumber
    ].filter(Boolean);

    const imageQuery = vehicleContext
        ? `${partNumber} ${vehicleContext} auto part`
        : `${partNumber} automotive part`;

    let webResponse = null;
    let usedQuery = null;

    // Try each search strategy until we get results
    for (const webQuery of searchStrategies) {
        try {
            console.log(`🔎 SerpAPI: trying "${webQuery}"`);
            
            const response = await axios.get('https://serpapi.com/search', {
                params: {
                    engine: 'google',
                    q: webQuery,
                    api_key: serpApiKey,
                    num: 5,
                    gl: 'us',
                    hl: 'en'
                },
                timeout: 10000
            });

            const organicResults = response.data.organic_results || [];
            
            if (organicResults.length > 0) {
                webResponse = response;
                usedQuery = webQuery;
                console.log(`✅ Found results with query: "${webQuery}"`);
                break;
            } else {
                console.log(`  ⚠️ No results for "${webQuery}", trying next strategy...`);
            }
        } catch (err) {
            console.error(`  ❌ Search error for "${webQuery}":`, err.message);
            continue;
        }
    }

    if (!webResponse) {
        console.log('❌ No results found with any search strategy');
        return null;
    }

    try {
        // Get image in parallel (don't block on image failure)
        const imageResponse = await axios.get('https://serpapi.com/search', {
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
        });

        const results = webResponse.data;
        const organicResults = results.organic_results || [];

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
        console.error('🔎 SerpAPI result processing error:', error.message);
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
 * Automatically parses structured barcodes to extract part numbers.
 * 
 * @param {string} partNumber - The part/article/OEM number or raw barcode to look up
 * @param {Object|null} vehicleData - Optional vehicle context { make, model, year }
 * @returns {Promise<Object|null>} Part details or null if not found
 */
export async function lookupPart(partNumber, vehicleData = null) {
    if (!partNumber || typeof partNumber !== 'string' || partNumber.trim().length === 0) {
        return null;
    }

    const rawInput = partNumber.trim();

    // Parse barcode to extract clean part number
    const extractedPartNumber = extractPartNumber(rawInput);
    const metadata = extractBarcodeMetadata(rawInput);

    if (rawInput !== extractedPartNumber) {
        console.log(`🔍 Raw barcode: "${rawInput}"`);
        console.log(`📦 Extracted part number: "${extractedPartNumber}"`);
        if (Object.keys(metadata).length > 0) {
            console.log(`📋 Metadata:`, metadata);
        }
    } else {
        console.log(`🔍 Part lookup: "${extractedPartNumber}"`);
    }

    // Enrich vehicle data with manufacturer from barcode if available
    const enrichedVehicleData = metadata.manufacturer && !vehicleData?.make
        ? { ...vehicleData, make: metadata.manufacturer }
        : vehicleData;

    const result = await lookupViaSerpApi(extractedPartNumber, enrichedVehicleData);
    if (result) {
        console.log('  ✅ Found via SerpAPI');
        // Include original raw barcode in response for reference
        if (rawInput !== extractedPartNumber) {
            result.rawBarcode = rawInput;
            result.barcodeMetadata = metadata;
        }
        return result;
    }

    console.log('  ❌ Part not found');
    return null;
}

export default { lookupPart };
