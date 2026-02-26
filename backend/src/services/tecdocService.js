/**
 * TecDoc Catalog Service
 *
 * Chains TecDoc RapidAPI endpoints to resolve VIN → Parts:
 *   1. VIN decode  → extract make, model, year
 *   2. Search manufacturers → find TecDoc manuId
 *   3. Search model series → find TecDoc modelId
 *   4. Model types → vehicleId list
 *   5. Vehicle parts → OEM part numbers grouped by product name
 *
 * API key is read from TECDOC_RAPIDAPI_KEY env var.
 */

const RAPIDAPI_HOST = 'tecdoc-catalog.p.rapidapi.com';
const FETCH_TIMEOUT = 45000;

/** Helper – build headers for every request */
function apiHeaders() {
    const apiKey = process.env.TECDOC_RAPIDAPI_KEY;
    if (!apiKey) throw new TecDocError('TECDOC_RAPIDAPI_KEY is not configured', 500);
    return { 'x-rapidapi-host': RAPIDAPI_HOST, 'x-rapidapi-key': apiKey };
}

/** Helper – fetch JSON from TecDoc API with timeout and error handling */
async function tecdocFetch(url, label) {
    console.log(`🔍 TecDoc ${label}: ${url}`);
    const res = await fetch(url, { method: 'GET', headers: apiHeaders(), signal: AbortSignal.timeout(FETCH_TIMEOUT) });
    console.log(`📡 TecDoc ${label} response: ${res.status} ${res.statusText}`);

    // Read raw text first to diagnose parsing issues
    const text = await res.text().catch(() => '');

    if (!res.ok) {
        console.error(`❌ TecDoc ${label} error: ${text.substring(0, 500)}`);
        throw new TecDocError(`TecDoc ${label} failed (${res.status}): ${text.substring(0, 200)}`, res.status);
    }

    if (!text || text.trim().length === 0) {
        console.error(`❌ TecDoc ${label} returned empty body`);
        return null;
    }

    console.log(`📦 TecDoc ${label} raw (first 500 chars): ${text.substring(0, 500)}`);

    try {
        return JSON.parse(text);
    } catch (e) {
        console.error(`❌ TecDoc ${label} JSON parse error: ${e.message}`);
        console.error(`📦 Full raw response: ${text.substring(0, 1000)}`);
        return null;
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 – Decode VIN
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Decode a VIN via TecDoc and extract make/model/year.
 * The API returns vin-data-1 (basic), vin-data-2 (NHTSA-style detail),
 * vin-data-3 (manufacturer info) with JSON strings in `content` fields.
 */
async function decodeVin(vinNo) {
    const url = `https://${RAPIDAPI_HOST}/vin/tecdoc-vin-check/${encodeURIComponent(vinNo)}`;
    const json = await tecdocFetch(url, 'VIN decode');

    if (!json || typeof json !== 'object') {
        throw new TecDocError('No vehicle data returned for this VIN', 404);
    }

    console.log(`📦 TecDoc VIN decode keys: ${Object.keys(json).join(', ')}`);

    // Parse the content JSON strings from vin-data-1/2/3
    const vinData1 = safeParseContent(json['vin-data-1']);
    const vinData2 = safeParseContent(json['vin-data-2']);
    const vinData3 = safeParseContent(json['vin-data-3']);

    // Also handle old format with matchingModels (in case API returns that for some VINs)
    const data = json.data ?? json;
    const matchingModels = data?.matchingModels?.array || data?.matchingModels || [];
    if (matchingModels.length > 0) {
        console.log(`✅ TecDoc returned legacy matchingModels format`);
        const matchingVehicles = data.matchingVehicles?.array || data.matchingVehicles || [];
        const matchingManufacturers = data.matchingManufacturers?.array || data.matchingManufacturers || [];
        return {
            format: 'legacy',
            modelId: matchingModels[0].modelId,
            modelName: matchingModels[0].modelName,
            manuId: matchingModels[0].manuId,
            manufacturer: matchingManufacturers[0]?.manuName || null,
            matchingVehicles: matchingVehicles.map(v => ({
                carId: v.carId,
                carName: v.carName,
                vehicleTypeDescription: v.vehicleTypeDescription,
            })),
        };
    }

    // Extract vehicle info from vin-data-2 (primary source) and vin-data-1 (fallback)
    const make = vinData2?.make || vinData1?.manufacturer || null;
    const model = vinData2?.model || null;
    const modelYear = vinData2?.model_year || (vinData1?.modelYear?.[1]) || null;
    const manufacturer = vinData1?.manufacturer || vinData2?.manufacturer_name || null;

    if (!make) {
        console.error(`❌ Could not extract make from VIN decode`, { vinData1, vinData2 });
        throw new TecDocError('Could not identify vehicle make from VIN', 404);
    }

    console.log(`✅ VIN decoded: ${modelYear} ${make} ${model || '(unknown model)'}`);

    return {
        format: 'vin-data',
        make: make.toUpperCase(),
        model,
        year: modelYear ? parseInt(modelYear, 10) : null,
        manufacturer,
        trim: vinData2?.trim || null,
        engineCylinders: vinData2?.['engine_number_of_cylinders'] || null,
        displacement: vinData2?.['displacement_(l)'] || null,
        driveType: vinData2?.drive_type || null,
        bodyClass: vinData2?.body_class || null,
    };
}

/** Safely parse a vin-data-N content field (may be a JSON string or already an object) */
function safeParseContent(vinDataEntry) {
    if (!vinDataEntry) return null;
    const content = vinDataEntry.content ?? vinDataEntry;
    if (typeof content === 'string') {
        try { return JSON.parse(content); } catch { return null; }
    }
    return typeof content === 'object' ? content : null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 – Find TecDoc manufacturer ID by name
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Get all manufacturers from TecDoc and find the one matching the given name.
 */
async function findManufacturerId(makeName, { typeId = '1', langId = '4', countryFilterId = '63' } = {}) {
    const url =
        `https://${RAPIDAPI_HOST}/manufacturers` +
        `/type-id/${typeId}` +
        `/lang-id/${langId}` +
        `/country-filter-id/${countryFilterId}`;

    const json = await tecdocFetch(url, 'manufacturers');
    const manufacturers = Array.isArray(json) ? json : (json?.manufacturers || json?.data || []);

    if (!Array.isArray(manufacturers) || manufacturers.length === 0) {
        console.error(`❌ No manufacturers returned from TecDoc`);
        throw new TecDocError('Could not retrieve manufacturer list from parts catalog', 500);
    }

    console.log(`📋 TecDoc returned ${manufacturers.length} manufacturers`);

    // Normalise search name
    const searchName = makeName.toUpperCase().trim();

    // Try exact match first, then startsWith, then includes
    const exact = manufacturers.find(m =>
        (m.manuName || m.manufacturerName || '').toUpperCase().trim() === searchName
    );
    if (exact) {
        console.log(`✅ Exact manufacturer match: ${exact.manuName || exact.manufacturerName} (id: ${exact.manuId || exact.manufacturerId})`);
        return exact.manuId || exact.manufacturerId;
    }

    const startsWith = manufacturers.find(m =>
        (m.manuName || m.manufacturerName || '').toUpperCase().startsWith(searchName)
    );
    if (startsWith) {
        console.log(`✅ StartsWith manufacturer match: ${startsWith.manuName || startsWith.manufacturerName} (id: ${startsWith.manuId || startsWith.manufacturerId})`);
        return startsWith.manuId || startsWith.manufacturerId;
    }

    const includes = manufacturers.find(m =>
        (m.manuName || m.manufacturerName || '').toUpperCase().includes(searchName)
    );
    if (includes) {
        console.log(`✅ Includes manufacturer match: ${includes.manuName || includes.manufacturerName} (id: ${includes.manuId || includes.manufacturerId})`);
        return includes.manuId || includes.manufacturerId;
    }

    // Log available manufacturers for debugging
    const available = manufacturers.slice(0, 20).map(m => m.manuName || m.manufacturerName).join(', ');
    console.error(`❌ No match for "${searchName}". Available (first 20): ${available}`);
    throw new TecDocError(`Manufacturer "${makeName}" not found in parts catalog`, 404);
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 – Find TecDoc model ID by manufacturer and model name
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Get model series for a manufacturer and find the one matching the model name.
 */
async function findModelId(manuId, modelName, year, { typeId = '1', langId = '4', countryFilterId = '63' } = {}) {
    const url =
        `https://${RAPIDAPI_HOST}/model-series` +
        `/manufacturer-id/${encodeURIComponent(manuId)}` +
        `/type-id/${typeId}` +
        `/lang-id/${langId}` +
        `/country-filter-id/${countryFilterId}`;

    const json = await tecdocFetch(url, 'model series');
    const models = Array.isArray(json) ? json : (json?.models || json?.modelSeries || json?.data || []);

    if (!Array.isArray(models) || models.length === 0) {
        console.error(`❌ No models returned for manufacturer ${manuId}`);
        throw new TecDocError('No models found for this manufacturer', 404);
    }

    console.log(`📋 TecDoc returned ${models.length} models for manufacturer ${manuId}`);

    if (!modelName) {
        // No model name — return the first model and let the user choose via vehicle selection
        console.log(`⚠️ No model name from VIN, using first model: ${models[0].modelName || models[0].modelSeriesName}`);
        return {
            modelId: models[0].modelId || models[0].modelSeriesId,
            modelName: models[0].modelName || models[0].modelSeriesName,
            allModels: models,
        };
    }

    const searchModel = modelName.toUpperCase().trim();

    // Score-based matching: prefer exact match > year-filtered > startsWith > includes
    let bestMatch = null;
    let bestScore = 0;

    for (const m of models) {
        const name = (m.modelName || m.modelSeriesName || '').toUpperCase().trim();

        let score = 0;
        if (name === searchModel) {
            score = 100;
        } else if (name.startsWith(searchModel) || searchModel.startsWith(name)) {
            score = 70;
        } else if (name.includes(searchModel) || searchModel.includes(name)) {
            score = 50;
        } else {
            continue;
        }

        // Boost if year falls within model production range
        if (year && m.yearOfConstrFrom && m.yearOfConstrTo) {
            const from = parseInt(m.yearOfConstrFrom, 10);
            const to = parseInt(m.yearOfConstrTo, 10) || 2099;
            if (year >= from && year <= to) {
                score += 20;
            }
        }

        if (score > bestScore) {
            bestScore = score;
            bestMatch = m;
        }
    }

    if (bestMatch) {
        const id = bestMatch.modelId || bestMatch.modelSeriesId;
        const name = bestMatch.modelName || bestMatch.modelSeriesName;
        console.log(`✅ Model match: ${name} (id: ${id}, score: ${bestScore})`);
        return { modelId: id, modelName: name, allModels: models };
    }

    // Log available models for debugging
    const available = models.slice(0, 15).map(m => m.modelName || m.modelSeriesName).join(', ');
    console.error(`❌ No match for model "${modelName}". Available (first 15): ${available}`);
    throw new TecDocError(`Model "${modelName}" not found for this manufacturer in parts catalog`, 404);
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 4 – Get vehicle types for a model
// ─────────────────────────────────────────────────────────────────────────────
async function getModelTypes(modelId, { langId = '4', countryFilterId = '63' } = {}) {
    const url =
        `https://${RAPIDAPI_HOST}/types/type-id/1` +
        `/list-vehicles-id/${encodeURIComponent(modelId)}` +
        `/lang-id/${encodeURIComponent(langId)}` +
        `/country-filter-id/${encodeURIComponent(countryFilterId)}`;

    const json = await tecdocFetch(url, 'model types');
    const modelTypes = Array.isArray(json) ? json : (json?.modelTypes || []);

    // Deduplicate by vehicleId
    const seen = new Set();
    const unique = [];
    for (const mt of modelTypes) {
        if (!seen.has(mt.vehicleId)) {
            seen.add(mt.vehicleId);
            unique.push({
                vehicleId: mt.vehicleId,
                manufacturerName: mt.manufacturerName,
                modelName: mt.modelName,
                typeEngineName: mt.typeEngineName,
            });
        }
    }

    return {
        modelType: json?.modelType || 'PC',
        count: unique.length,
        vehicles: unique,
    };
}

/**
 * Step 5 – Retrieve OEM parts for a specific vehicleId
 */
async function getVehicleParts(vehicleId, { langId = '4', searchParam = '-' } = {}) {
    const url =
        `https://${RAPIDAPI_HOST}/articles-oem` +
        `/selecting-oem-parts-vehicle-modification-description-product-group` +
        `/type-id/1/vehicle-id/${encodeURIComponent(vehicleId)}` +
        `/lang-id/${encodeURIComponent(langId)}` +
        `/search-param/${encodeURIComponent(searchParam)}`;

    const json = await tecdocFetch(url, 'vehicle parts');
    const parts = Array.isArray(json) ? json : (json?.parts || json?.data || []);

    // Group parts by product name for a cleaner response
    const grouped = {};
    for (const p of (Array.isArray(parts) ? parts : [])) {
        const name = p.articleProductName || 'Unknown';
        if (!grouped[name]) grouped[name] = [];
        grouped[name].push(p.articleOemNo);
    }

    const categories = Object.entries(grouped).map(([name, oemNumbers]) => ({
        productName: name,
        count: oemNumbers.length,
        oemNumbers,
    }));

    return {
        totalParts: Array.isArray(parts) ? parts.length : 0,
        categories,
        raw: Array.isArray(parts) ? parts : [],
    };
}

/**
 * Full chain: VIN → make/model → TecDoc IDs → auto-select vehicle → parts
 */
async function vinToParts(vinNo) {
    // Step 1 – decode VIN to get make, model, year
    const vinData = await decodeVin(vinNo);

    let modelId, modelName, manufacturer;

    if (vinData.format === 'legacy' && vinData.modelId) {
        // Old API format — modelId comes directly from VIN decode
        modelId = vinData.modelId;
        modelName = vinData.modelName;
        manufacturer = vinData.manufacturer;
    } else {
        // New API format — need to search for manufacturer → model → vehicle
        console.log(`🔗 Resolving TecDoc IDs for: ${vinData.make} ${vinData.model || ''}`);

        // Step 2 – find manufacturer ID
        const manuId = await findManufacturerId(vinData.make);
        manufacturer = vinData.make;

        // Step 3 – find model ID
        const modelResult = await findModelId(manuId, vinData.model, vinData.year);
        modelId = modelResult.modelId;
        modelName = modelResult.modelName;
    }

    // Step 4 – get vehicle types for this model
    const modelTypes = await getModelTypes(modelId);

    // Auto-select best vehicle variant
    let selectedVehicle = null;

    // For legacy format, try matching by carId
    if (vinData.format === 'legacy' && vinData.matchingVehicles?.length > 0) {
        const carId = vinData.matchingVehicles[0].carId;
        selectedVehicle = modelTypes.vehicles.find(v => v.vehicleId === carId) || null;
    }

    // If no exact match, pick the first vehicle
    if (!selectedVehicle && modelTypes.vehicles.length > 0) {
        selectedVehicle = modelTypes.vehicles[0];
    }

    if (!selectedVehicle) {
        throw new TecDocError('No vehicle variants found for this model', 404);
    }

    // Return vehicle info only — parts are fetched on-demand via search
    return {
        vin: vinNo,
        manufacturer,
        modelName,
        selectedVehicle,
        availableVehicles: modelTypes.vehicles,
    };
}

/** Custom error class */
class TecDocError extends Error {
    constructor(message, statusCode = 500) {
        super(message);
        this.name = 'TecDocError';
        this.statusCode = statusCode;
    }
}

export default { decodeVin, findManufacturerId, findModelId, getModelTypes, getVehicleParts, vinToParts, TecDocError };
