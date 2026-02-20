/**
 * TecDoc Catalog API Service
 *
 * Proxies requests to the TecDoc API on RapidAPI, with an in-memory cache
 * layer to minimise redundant calls and speed up repeat lookups.
 *
 * Flow:
 *   1. Decode VIN  → vehicle IDs
 *   2. Get categories for vehicle
 *   3. Get article (part) details + media
 */

const RAPIDAPI_HOST = 'tecdoc-catalog.p.rapidapi.com';
const BASE_URL = `https://${RAPIDAPI_HOST}`;

// Default language / country IDs (English, Germany)
const DEFAULT_LANG_ID = 4;     // English
const DEFAULT_COUNTRY_ID = 6;  // Germany
const DEFAULT_TYPE_ID = 1;     // Passenger car

// Cache TTL: 24 hours
const CACHE_TTL_MS = 24 * 60 * 60 * 1000;

// ---------------------------------------------------------------------------
// In-memory cache
// ---------------------------------------------------------------------------
const cache = new Map();

function cacheGet(key) {
    const entry = cache.get(key);
    if (!entry) return null;
    if (Date.now() - entry.ts > CACHE_TTL_MS) {
        cache.delete(key);
        return null;
    }
    return entry.data;
}

function cacheSet(key, data) {
    cache.set(key, { data, ts: Date.now() });
}

function getCacheStats() {
    let valid = 0;
    let expired = 0;
    const now = Date.now();
    for (const [, entry] of cache) {
        if (now - entry.ts > CACHE_TTL_MS) expired++;
        else valid++;
    }
    return { total: cache.size, valid, expired };
}

function clearCache() {
    cache.clear();
}

// ---------------------------------------------------------------------------
// RapidAPI fetch helper
// ---------------------------------------------------------------------------
async function tecdocFetch(path) {
    const apiKey = process.env.TECDOC_RAPIDAPI_KEY;
    if (!apiKey) {
        throw Object.assign(new Error('TECDOC_RAPIDAPI_KEY not configured'), {
            name: 'TecDocConfigError',
            statusCode: 500,
            code: 'CONFIG_ERROR',
        });
    }

    const url = `${BASE_URL}${path}`;
    console.log(`[TecDoc] GET ${url}`);

    const res = await fetch(url, {
        method: 'GET',
        headers: {
            'x-rapidapi-key': apiKey,
            'x-rapidapi-host': RAPIDAPI_HOST,
        },
    });

    if (!res.ok) {
        const body = await res.text().catch(() => '');
        throw Object.assign(
            new Error(`TecDoc API ${res.status}: ${body || res.statusText}`),
            { name: 'TecDocApiError', statusCode: res.status, code: 'API_ERROR' },
        );
    }

    return res.json();
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

/**
 * Decode a VIN and return vehicle identification IDs.
 */
async function decodeVin(vin) {
    const cacheKey = `vin:${vin}`;
    const cached = cacheGet(cacheKey);
    if (cached) return cached;

    const data = await tecdocFetch(`/vin/decoder-v2/${encodeURIComponent(vin)}`);
    cacheSet(cacheKey, data);
    return data;
}

/**
 * Get part categories for a decoded vehicle.
 */
async function getCategories(vehicleId, manufacturerId, {
    langId = DEFAULT_LANG_ID,
    countryFilterId = DEFAULT_COUNTRY_ID,
    typeId = DEFAULT_TYPE_ID,
} = {}) {
    const cacheKey = `cat:${vehicleId}:${manufacturerId}:${langId}:${countryFilterId}:${typeId}`;
    const cached = cacheGet(cacheKey);
    if (cached) return cached;

    const path = `/category/category-products-groups-variant-1/${vehicleId}/manufacturer-id/${manufacturerId}/lang-id/${langId}/country-filter-id/${countryFilterId}/type-id/${typeId}`;
    const data = await tecdocFetch(path);
    cacheSet(cacheKey, data);
    return data;
}

/**
 * Get full article (part) details by article ID.
 */
async function getArticleDetails(articleId, {
    langId = DEFAULT_LANG_ID,
    countryFilterId = DEFAULT_COUNTRY_ID,
} = {}) {
    const cacheKey = `art:${articleId}:${langId}:${countryFilterId}`;
    const cached = cacheGet(cacheKey);
    if (cached) return cached;

    const path = `/articles/article-id-details/${articleId}/lang-id/${langId}/country-filter-id/${countryFilterId}`;
    const data = await tecdocFetch(path);
    cacheSet(cacheKey, data);
    return data;
}

/**
 * Get media (images) for an article.
 */
async function getArticleMedia(articleId, {
    langId = DEFAULT_LANG_ID,
} = {}) {
    const cacheKey = `media:${articleId}:${langId}`;
    const cached = cacheGet(cacheKey);
    if (cached) return cached;

    const path = `/articles/article-all-media-info/${articleId}/lang-id/${langId}`;
    const data = await tecdocFetch(path);
    cacheSet(cacheKey, data);
    return data;
}

/**
 * Search articles by article number.
 */
async function searchByArticleNumber(articleNumber, {
    langId = DEFAULT_LANG_ID,
} = {}) {
    const cacheKey = `search:${articleNumber}:${langId}`;
    const cached = cacheGet(cacheKey);
    if (cached) return cached;

    const path = `/articles/search/lang-id/${langId}/article-search/${encodeURIComponent(articleNumber)}`;
    const data = await tecdocFetch(path);
    cacheSet(cacheKey, data);
    return data;
}

export default {
    decodeVin,
    getCategories,
    getArticleDetails,
    getArticleMedia,
    searchByArticleNumber,
    getCacheStats,
    clearCache,
};
