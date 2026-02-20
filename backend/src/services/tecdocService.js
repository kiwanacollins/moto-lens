/**
 * TecDoc Catalog API Service
 *
 * Proxies requests to the TecDoc API on RapidAPI, with an in-memory cache
 * layer to minimise redundant calls and speed up repeat lookups.
 *
 * Confirmed working endpoints (PRO plan):
 *   - vin/decoder-v2/{vin}
 *   - manufacturers/find-by-id/{id}
 *   - articles/search-by-article-no/lang-id/{langId}/article-no/{articleNo}
 *   - articles/article-all-media-info/article-id/{articleId}/lang-id/{langId}
 *   - articles/get-article-category/article-id/{articleId}/lang-id/{langId}
 *   - suppliers/list
 */

const RAPIDAPI_HOST = 'auto-parts-catalog.p.rapidapi.com';
const BASE_URL = `https://${RAPIDAPI_HOST}`;

const DEFAULT_LANG_ID = 4; // English

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
 * Decode a VIN and return vehicle identification data.
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
 * Search articles by part/article number.
 * Returns { articleNo, countArticles, articles: [...] }
 */
async function searchByArticleNumber(articleNumber, {
    langId = DEFAULT_LANG_ID,
} = {}) {
    const cacheKey = `search:${articleNumber}:${langId}`;
    const cached = cacheGet(cacheKey);
    if (cached) return cached;

    const path = `/articles/search-by-article-no/lang-id/${langId}/article-no/${encodeURIComponent(articleNumber)}`;
    const data = await tecdocFetch(path);
    cacheSet(cacheKey, data);
    return data;
}

/**
 * Get media (images) for an article by its ID.
 */
async function getArticleMedia(articleId, {
    langId = DEFAULT_LANG_ID,
} = {}) {
    const cacheKey = `media:${articleId}:${langId}`;
    const cached = cacheGet(cacheKey);
    if (cached) return cached;

    const path = `/articles/article-all-media-info/article-id/${articleId}/lang-id/${langId}`;
    const data = await tecdocFetch(path);
    cacheSet(cacheKey, data);
    return data;
}

/**
 * Get category info for an article by its ID.
 */
async function getArticleCategory(articleId, {
    langId = DEFAULT_LANG_ID,
} = {}) {
    const cacheKey = `artcat:${articleId}:${langId}`;
    const cached = cacheGet(cacheKey);
    if (cached) return cached;

    const path = `/articles/get-article-category/article-id/${articleId}/lang-id/${langId}`;
    const data = await tecdocFetch(path);
    cacheSet(cacheKey, data);
    return data;
}

/**
 * Get manufacturer details by ID.
 */
async function getManufacturer(manufacturerId) {
    const cacheKey = `manu:${manufacturerId}`;
    const cached = cacheGet(cacheKey);
    if (cached) return cached;

    const data = await tecdocFetch(`/manufacturers/find-by-id/${manufacturerId}`);
    cacheSet(cacheKey, data);
    return data;
}

/**
 * List all suppliers.
 */
async function getSuppliers() {
    const cacheKey = 'suppliers';
    const cached = cacheGet(cacheKey);
    if (cached) return cached;

    const data = await tecdocFetch('/suppliers/list');
    cacheSet(cacheKey, data);
    return data;
}

export default {
    decodeVin,
    searchByArticleNumber,
    getArticleMedia,
    getArticleCategory,
    getManufacturer,
    getSuppliers,
    getCacheStats,
    clearCache,
};
