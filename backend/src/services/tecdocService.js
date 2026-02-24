/**
 * TecDoc Catalog Service
 *
 * Chains three TecDoc RapidAPI endpoints to resolve VIN → Parts:
 *   1. VIN decode  → modelId + carId
 *   2. Model types → vehicleId list
 *   3. Vehicle parts → OEM part numbers grouped by product name
 *
 * API key is read from TECDOC_RAPIDAPI_KEY env var.
 */

const RAPIDAPI_HOST = 'tecdoc-catalog.p.rapidapi.com';

/**
 * Step 1 – Decode a VIN and return matching models / vehicles
 */
async function decodeVin(vinNo) {
    const apiKey = process.env.TECDOC_RAPIDAPI_KEY;
    if (!apiKey) throw new TecDocError('TECDOC_RAPIDAPI_KEY is not configured', 500);

    const url = `https://${RAPIDAPI_HOST}/vin/resolve?vinNo=${encodeURIComponent(vinNo)}`;

    const res = await fetch(url, {
        method: 'GET',
        headers: {
            'x-rapidapi-host': RAPIDAPI_HOST,
            'x-rapidapi-key': apiKey,
        },
    });

    if (!res.ok) {
        const text = await res.text().catch(() => '');
        throw new TecDocError(`TecDoc VIN decode failed (${res.status}): ${text}`, res.status);
    }

    const json = await res.json();

    // The API wraps the useful data inside `data.dataSource[0]`
    const dataSource = json?.data?.dataSource?.[0];
    if (!dataSource) {
        throw new TecDocError('No vehicle data returned for this VIN', 404);
    }

    const matchingVehicles = dataSource.matchingVehicles || [];
    const matchingModels = dataSource.matchingModels || [];
    const matchingManufacturers = dataSource.matchingManufacturers || [];

    if (matchingModels.length === 0) {
        throw new TecDocError('VIN did not match any known model', 404);
    }

    return {
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

/**
 * Step 2 – Retrieve all vehicle types for a given modelId
 */
async function getModelTypes(modelId, { langId = '4', countryFilterId = '63' } = {}) {
    const apiKey = process.env.TECDOC_RAPIDAPI_KEY;
    if (!apiKey) throw new TecDocError('TECDOC_RAPIDAPI_KEY is not configured', 500);

    const url =
        `https://${RAPIDAPI_HOST}/vehicle/types` +
        `?typeId=1&modelId=${encodeURIComponent(modelId)}` +
        `&langId=${encodeURIComponent(langId)}` +
        `&countryFilterId=${encodeURIComponent(countryFilterId)}`;

    const res = await fetch(url, {
        method: 'GET',
        headers: {
            'x-rapidapi-host': RAPIDAPI_HOST,
            'x-rapidapi-key': apiKey,
        },
    });

    if (!res.ok) {
        const text = await res.text().catch(() => '');
        throw new TecDocError(`TecDoc model types failed (${res.status}): ${text}`, res.status);
    }

    const json = await res.json();
    const modelTypes = json?.modelTypes || [];

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
 * Step 3 – Retrieve OEM parts for a specific vehicleId
 */
async function getVehicleParts(vehicleId, { langId = '4', searchParam = 'filter' } = {}) {
    const apiKey = process.env.TECDOC_RAPIDAPI_KEY;
    if (!apiKey) throw new TecDocError('TECDOC_RAPIDAPI_KEY is not configured', 500);

    const url =
        `https://${RAPIDAPI_HOST}/vehicle/parts` +
        `?typeId=1&vehicleId=${encodeURIComponent(vehicleId)}` +
        `&langId=${encodeURIComponent(langId)}` +
        `&searchParam=${encodeURIComponent(searchParam)}`;

    const res = await fetch(url, {
        method: 'GET',
        headers: {
            'x-rapidapi-host': RAPIDAPI_HOST,
            'x-rapidapi-key': apiKey,
        },
    });

    if (!res.ok) {
        const text = await res.text().catch(() => '');
        throw new TecDocError(`TecDoc vehicle parts failed (${res.status}): ${text}`, res.status);
    }

    const parts = await res.json();

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
 * Full chain: VIN → modelId → auto-select vehicleId → parts
 */
async function vinToParts(vinNo) {
    // Step 1 – decode VIN
    const vinData = await decodeVin(vinNo);

    // Step 2 – get model types
    const modelTypes = await getModelTypes(vinData.modelId);

    // Try to auto-select the matching vehicleId from the VIN decode's carId
    let selectedVehicle = null;
    if (vinData.matchingVehicles.length > 0) {
        const carId = vinData.matchingVehicles[0].carId;
        selectedVehicle = modelTypes.vehicles.find(v => v.vehicleId === carId) || null;
    }

    // If no exact match, pick the first one
    if (!selectedVehicle && modelTypes.vehicles.length > 0) {
        selectedVehicle = modelTypes.vehicles[0];
    }

    if (!selectedVehicle) {
        throw new TecDocError('No vehicle variants found for this model', 404);
    }

    // Step 3 – fetch parts
    const partsData = await getVehicleParts(selectedVehicle.vehicleId);

    return {
        vin: vinNo,
        manufacturer: vinData.manufacturer,
        modelName: vinData.modelName,
        selectedVehicle,
        availableVehicles: modelTypes.vehicles,
        parts: partsData,
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

export default { decodeVin, getModelTypes, getVehicleParts, vinToParts, TecDocError };
