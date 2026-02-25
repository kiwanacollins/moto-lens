import { generateResponse } from './geminiAiService.js';

/**
 * Vehicle Data Enrichment Service
 * Uses AI to fill in missing vehicle specifications based on make, model, year
 * Implements caching and consistency to prevent repeated/conflicting enrichments
 * Includes circuit breaker pattern to handle API rate limits gracefully
 */
class VehicleEnrichmentService {
    constructor() {
        // In-memory cache for enrichment results (prevents inconsistent AI responses)
        this.enrichmentCache = new Map();

        // Cache TTL: 4 hours (in milliseconds) - longer to reduce API calls
        this.cacheTimeout = 4 * 60 * 60 * 1000;

        // Circuit breaker for rate limit protection
        this.circuitBreaker = {
            failureCount: 0,
            lastFailureTime: 0,
            maxFailures: 3,
            cooldownPeriod: 5 * 60 * 1000, // 5 minutes
            isOpen: false
        };
    }
    /**
     * Enriches vehicle data by predicting missing specifications using AI
     * Uses caching to ensure consistent results for the same vehicle
     * @param {Object} vehicleData - Base vehicle data from VIN decode
     * @returns {Object} - Enriched vehicle data with AI-predicted specifications
     */
    async enrichVehicleData(vehicleData) {
        try {
            const { make, model, year, vin } = vehicleData;

            // Check circuit breaker first - skip enrichment if too many recent failures
            if (this.isCircuitBreakerOpen()) {
                console.log('⚡ Circuit breaker OPEN - skipping enrichment to prevent rate limit');
                return {
                    ...vehicleData,
                    _enriched: false,
                    _enrichmentSkipped: 'Circuit breaker active due to rate limits'
                };
            }

            // Skip enrichment if already has good data
            if (this.hasGoodData(vehicleData)) {
                console.log('Vehicle already has good data, skipping enrichment');
                return vehicleData;
            }

            // Create cache key for consistent results
            const cacheKey = this.createCacheKey(make, model, year, vin);

            // Check cache first
            const cached = this.getCachedEnrichment(cacheKey);
            if (cached) {
                console.log('Using cached enrichment data');
                return this.mergeWithCache(vehicleData, cached);
            }

            // Only enrich fields that are missing or insufficient
            const fieldsToEnrich = this.identifyFieldsToEnrich(vehicleData);

            if (fieldsToEnrich.length === 0) {
                console.log('No fields need enrichment');
                return vehicleData;
            }

            console.log(`Enriching fields: ${fieldsToEnrich.join(', ')}`);

            // Create a targeted prompt for missing fields only
            const enrichmentPrompt = this.createTargetedEnrichmentPrompt(make, model, year, fieldsToEnrich);

            // Get AI predictions
            const aiResponse = await generateResponse(enrichmentPrompt);

            // Successful API call - reset circuit breaker
            this.resetCircuitBreaker();

            // Parse AI response into structured data
            const enrichedSpecs = this.parseAiResponse(aiResponse, vehicleData, fieldsToEnrich);

            // Cache the enriched specs
            this.cacheEnrichment(cacheKey, enrichedSpecs);

            // Merge with original data, preserving any existing valid values
            const enrichedData = {
                ...vehicleData,
                ...this.selectivelyMerge(vehicleData, enrichedSpecs),
                // Add metadata about enrichment
                _enriched: true,
                _enrichedAt: new Date().toISOString(),
                _enrichedFields: Object.keys(enrichedSpecs),
                _enrichedFrom: 'ai-prediction'
            };

            return enrichedData;
        } catch (error) {
            console.error('Error enriching vehicle data:', error);

            // Handle rate limit errors with circuit breaker
            if (error.code === 'RATE_LIMIT') {
                this.recordFailure();
                console.warn('⚡ Opening circuit breaker due to rate limit');
            }

            // Return original data if enrichment fails
            return {
                ...vehicleData,
                _enriched: false,
                _enrichmentError: error.message
            };
        }
    }

    /**
     * Check if vehicle data already has sufficient information
     * @param {Object} vehicleData - Vehicle data to check
     * @returns {boolean} - True if data is already good
     */
    hasGoodData(vehicleData) {
        // MODEL is critical - never skip enrichment if model is missing
        if (!vehicleData.model || vehicleData.model === 'Not specified' || vehicleData.model === 'Unknown' || vehicleData.model === null) {
            return false;
        }

        const criticalFields = ['make', 'model', 'year', 'engine', 'bodyType'];
        const validFields = criticalFields.filter(field => {
            const value = vehicleData[field];
            return value && value !== 'Not specified' && value !== 'Unknown' && value !== null;
        });

        // More conservative - consider data good if we have at least 3 out of 5 critical fields
        // This reduces unnecessary API calls to save rate limits
        return validFields.length >= 3;
    }

    /**
     * Identify which fields need enrichment
     * @param {Object} vehicleData - Current vehicle data
     * @returns {Array} - Array of field names that need enrichment
     */
    identifyFieldsToEnrich(vehicleData) {
        // Include 'model' as enrichable since some VIN decoders fail to return it
        const enrichableFields = [
            'model', 'engine', 'bodyType', 'transmission', 'drivetrain',
            'trim', 'fuelType', 'displacement', 'cylinders',
            'horsepower', 'torque', 'doors', 'seats'
        ];

        return enrichableFields.filter(field => {
            const value = vehicleData[field];
            return !value || value === 'Not specified' || value === 'Unknown' || value === null;
        });
    }

    /**
     * Create cache key for vehicle data
     * @param {string} make - Vehicle make
     * @param {string} model - Vehicle model  
     * @param {number} year - Vehicle year
     * @param {string} vin - Vehicle VIN (for uniqueness)
     * @returns {string} - Cache key
     */
    createCacheKey(make, model, year, vin) {
        // Use VIN if available for uniqueness, otherwise use make/model/year
        if (vin && vin.length === 17) {
            return `vin_${vin}`;
        }
        return `vehicle_${year}_${make}_${model}`.toLowerCase().replace(/\s+/g, '_');
    }

    /**
     * Get cached enrichment data
     * @param {string} cacheKey - Cache key
     * @returns {Object|null} - Cached data or null
     */
    getCachedEnrichment(cacheKey) {
        // TEMPORARILY DISABLED: Force fresh enrichment calls
        return null;

        /* Original cache logic (re-enable later)
        const cached = this.enrichmentCache.get(cacheKey);
        if (!cached) return null;

        // Check if cache has expired
        if (Date.now() - cached.timestamp > this.cacheTimeout) {
            this.enrichmentCache.delete(cacheKey);
            return null;
        }

        return cached.data;
        */
    }

    /**
     * Cache enrichment data
     * @param {string} cacheKey - Cache key
     * @param {Object} data - Data to cache
     */
    cacheEnrichment(cacheKey, data) {
        this.enrichmentCache.set(cacheKey, {
            data,
            timestamp: Date.now()
        });

        // Clean up old cache entries periodically
        if (this.enrichmentCache.size > 100) {
            this.cleanupCache();
        }
    }

    /**
     * Clean up expired cache entries
     */
    cleanupCache() {
        const now = Date.now();
        for (const [key, value] of this.enrichmentCache.entries()) {
            if (now - value.timestamp > this.cacheTimeout) {
                this.enrichmentCache.delete(key);
            }
        }
    }

    /**
     * Merge vehicle data with cached enrichment
     * @param {Object} vehicleData - Original vehicle data
     * @param {Object} cachedData - Cached enrichment data
     * @returns {Object} - Merged data
     */
    mergeWithCache(vehicleData, cachedData) {
        return {
            ...vehicleData,
            ...this.selectivelyMerge(vehicleData, cachedData),
            _enriched: true,
            _enrichedAt: new Date().toISOString(),
            _enrichedFields: Object.keys(cachedData),
            _enrichedFrom: 'cache'
        };
    }

    /**
     * Selectively merge enriched data, only overriding missing/poor fields
     * @param {Object} original - Original vehicle data
     * @param {Object} enriched - Enriched data
     * @returns {Object} - Selectively merged data
     */
    selectivelyMerge(original, enriched) {
        const merged = {};

        for (const [key, value] of Object.entries(enriched)) {
            const originalValue = original[key];

            // Only use enriched value if original is missing or poor quality
            if (!originalValue ||
                originalValue === 'Not specified' ||
                originalValue === 'Unknown' ||
                originalValue === null ||
                originalValue === '') {
                merged[key] = value;
            }
        }

        return merged;
    }

    /**
     * Creates a detailed prompt for AI vehicle specification prediction
     */
    createEnrichmentPrompt(make, model, year, currentData) {
        // Strip VIN identifier fields — AI should never return these (inaccurate)
        const { vin, wmi, vds, vis, vinValid, checksum, _raw, _source, ...safeData } = currentData;
        return `You are an automotive database expert. Based on the vehicle information provided, predict the most likely technical specifications.

Vehicle: ${year} ${make} ${model}
Current decode data: ${JSON.stringify(safeData, null, 2)}

Please provide ONLY a JSON response with these exact fields (use realistic specifications based on the vehicle):

{
  "engine": "Detailed engine specification (e.g., '2.0L TSI 4-cylinder turbo', '1.4L TDI diesel')",
  "bodyType": "Body style (e.g., 'Hatchback', 'Sedan', 'SUV', 'Coupe', 'Wagon')",
  "transmission": "Transmission type (e.g., '6-speed manual', '8-speed automatic DSG', 'CVT')",
  "drivetrain": "Drive type (e.g., 'Front-wheel drive', 'All-wheel drive', 'Rear-wheel drive')",
  "trim": "Most common trim level (e.g., 'SE', 'SEL', 'R-Line', 'GTI')",
  "fuelType": "Fuel type (e.g., 'Gasoline', 'Diesel', 'Hybrid', 'Electric')",
  "displacement": "Engine displacement in liters (e.g., '2.0', '1.8', '3.0')",
  "cylinders": "Number of cylinders (e.g., 4, 6, 8)",
  "horsepower": "Estimated horsepower (e.g., '147 hp', '220 hp')",
  "torque": "Estimated torque (e.g., '184 lb-ft', '258 lb-ft')",
  "doors": "Number of doors (e.g., 2, 4, 5)",
  "seats": "Number of seats (e.g., 2, 4, 5, 7)"
}

Guidelines:
- Use realistic specifications for this specific year/make/model combination
- Be specific and professional (no generic terms)
- For German vehicles (BMW, Audi, Mercedes, VW, Porsche), use European specifications
- If multiple variants exist, choose the most common/base model specifications
- Ensure all values are realistic and accurate for the vehicle
- Do not include any markdown formatting, only pure JSON

RESPOND ONLY WITH THE JSON OBJECT, NO OTHER TEXT.`;
    }

    /**
     * Parses AI response and validates the data
     */
    parseAiResponse(aiResponse, originalData, fieldsToEnrich = []) {
        try {
            // Clean the response (remove any markdown or extra text)
            let cleanedResponse = aiResponse.trim();

            // Extract JSON if wrapped in markdown
            const jsonMatch = cleanedResponse.match(/\{[\s\S]*\}/);
            if (jsonMatch) {
                cleanedResponse = jsonMatch[0];
            }

            const parsed = JSON.parse(cleanedResponse);

            // VIN identifier fields must NEVER come from AI (inaccurate)
            const VIN_FIELDS = ['vin', 'wmi', 'vds', 'vis', 'vinValid', 'checksum', '_raw', '_source'];

            // If we have specific fields to enrich, only validate those
            // Include 'model' in the default list since some VIN decoders fail to return it
            const targetFields = (fieldsToEnrich.length > 0 ? fieldsToEnrich :
                ['model', 'engine', 'bodyType', 'transmission', 'drivetrain', 'trim', 'fuelType', 'displacement', 'cylinders', 'horsepower', 'torque', 'doors', 'seats']
            ).filter(f => !VIN_FIELDS.includes(f));

            const validatedData = {};

            targetFields.forEach(field => {
                if (parsed[field] && parsed[field] !== 'Not specified' && parsed[field] !== null && parsed[field] !== '') {
                    validatedData[field] = parsed[field];
                }
            });

            return validatedData;
        } catch (error) {
            console.error('Error parsing AI response:', error);
            console.error('Raw AI response:', aiResponse);
            return {};
        }
    }

    /**
     * Creates a targeted prompt for specific missing fields only
     * @param {string} make - Vehicle make
     * @param {string} model - Vehicle model
     * @param {number} year - Vehicle year
     * @param {Array} fieldsToEnrich - Array of field names to enrich
     * @returns {string} - AI prompt
     */
    createTargetedEnrichmentPrompt(make, model, year, fieldsToEnrich) {
        // Define deterministic specifications for common German vehicles
        const vehicleSpecs = this.getDeterministicSpecs(make, model, year);

        const vehicleDescription = model ? `${year} ${make} ${model}` : `${year} ${make} (model unknown - please identify based on typical ${make} vehicles from that year)`;

        return `You are an automotive specification database. Provide the EXACT technical specifications for this vehicle.

Vehicle: ${vehicleDescription}

Required fields to complete: ${fieldsToEnrich.join(', ')}

IMPORTANT RULES:
1. Be deterministic - same vehicle = same specs every time
2. Use official manufacturer specifications
3. For German vehicles, use European/metric specifications
4. Choose the most common base/standard trim configuration
5. Return ONLY JSON, no other text
${fieldsToEnrich.includes('model') ? '6. For "model", return the most likely model name based on make and year (e.g., "Range Rover Sport" for Land Rover, "3 Series" for BMW)' : ''}

Expected JSON format:
{${fieldsToEnrich.map(field => `\n  "${field}": "${this.getFieldExample(field, make)}"`).join(',')}
}

For ${make} vehicles specifically:
${vehicleSpecs ? `Use these official specs: ${JSON.stringify(vehicleSpecs, null, 2)}` : 'Follow typical specifications for this manufacturer'}

RESPOND WITH ONLY THE JSON OBJECT:`;
    }

    /**
     * Get example field format for prompting
     * @param {string} field - Field name
     * @param {string} make - Vehicle make for context
     * @returns {string} - Example format
     */
    getFieldExample(field, make) {
        const examples = {
            'model': make === 'LAND ROVER' ? 'Range Rover Sport' : (make === 'BMW' ? '3 Series' : 'Model Name'),
            'engine': make === 'Volkswagen' ? '1.4L TSI 4-cylinder turbo' : '2.0L 4-cylinder turbo',
            'bodyType': 'Hatchback',
            'transmission': make === 'Volkswagen' ? '6-speed manual' : '6-speed automatic',
            'drivetrain': 'Front-wheel drive',
            'trim': 'Base',
            'fuelType': 'Gasoline',
            'displacement': '1.4',
            'cylinders': 4,
            'horsepower': '147 hp',
            'torque': '184 lb-ft',
            'doors': 5,
            'seats': 5
        };
        return examples[field] || 'specification';
    }

    /**
     * Get deterministic specifications for known vehicles
     * @param {string} make - Vehicle make
     * @param {string} model - Vehicle model
     * @param {number} year - Vehicle year
     * @returns {Object|null} - Known specifications or null
     */
    getDeterministicSpecs(make, model, year) {
        const makeUpper = make?.toUpperCase();
        const modelUpper = model?.toUpperCase();

        // Volkswagen Golf specifications by year
        if (makeUpper === 'VOLKSWAGEN' && modelUpper === 'GOLF') {
            if (year >= 2020) {
                return {
                    engine: '1.4L TSI 4-cylinder turbo',
                    bodyType: 'Hatchback',
                    transmission: '6-speed manual',
                    drivetrain: 'Front-wheel drive',
                    trim: 'Life',
                    fuelType: 'Gasoline',
                    displacement: '1.4',
                    cylinders: 4,
                    horsepower: '147 hp',
                    torque: '184 lb-ft',
                    doors: 5,
                    seats: 5
                };
            }
        }

        // Add more known vehicles here as needed...

        return null;
    }

    /**
     * Circuit breaker methods for rate limit protection
     */
    isCircuitBreakerOpen() {
        if (!this.circuitBreaker.isOpen) return false;

        // Check if cooldown period has passed
        if (Date.now() - this.circuitBreaker.lastFailureTime > this.circuitBreaker.cooldownPeriod) {
            this.resetCircuitBreaker();
            return false;
        }

        return true;
    }

    recordFailure() {
        this.circuitBreaker.failureCount++;
        this.circuitBreaker.lastFailureTime = Date.now();

        if (this.circuitBreaker.failureCount >= this.circuitBreaker.maxFailures) {
            this.circuitBreaker.isOpen = true;
            console.warn(`🚨 Circuit breaker opened after ${this.circuitBreaker.failureCount} failures`);
        }
    }

    resetCircuitBreaker() {
        if (this.circuitBreaker.isOpen) {
            console.log('🔄 Circuit breaker closed - enrichment resumed');
        }
        this.circuitBreaker.failureCount = 0;
        this.circuitBreaker.lastFailureTime = 0;
        this.circuitBreaker.isOpen = false;
    }

    /**
     * Quick enrichment for essential fields only (faster response)
     */
    async quickEnrich(make, model, year) {
        const quickPrompt = `Vehicle: ${year} ${make} ${model}

Provide ONLY JSON with essential specs:
{
  "engine": "Engine spec",
  "bodyType": "Body type", 
  "transmission": "Transmission",
  "drivetrain": "Drive type"
}

NO other text, only JSON:`;

        try {
            const response = await generateResponse(quickPrompt);
            return this.parseAiResponse(response, {});
        } catch (error) {
            console.error('Quick enrichment failed:', error);
            return {};
        }
    }
}

export default new VehicleEnrichmentService();