import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

// Get directory path for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Load environment variables from backend root
dotenv.config({ path: join(__dirname, '..', '.env') });

// Routes
import authRoutes from './routes/auth.js';

// Security Middleware
import {
    securityHeaders,
    productionCorsOptions,
    globalRateLimit,
    vinDecodeRateLimit,
    sanitizeInput,
    preventXSS,
    validateSqlInput,
    securityLogger,
} from './middleware/security.js';

// Services
import multiProviderVinService from './services/multiProviderVinService.js';
import vinUtils from './utils/vinValidator.js';
import geminiAiService from './services/geminiAiService.js';
import geminiVisionService from './services/geminiVisionService.js';
import vehicleEnrichmentService from './services/vehicleEnrichmentService.js';
import {
    searchVehicleImages,
    searchPartImages,
    clearSearchCache,
    getCacheStats
} from './services/webImageSearchService.js';
import partLookupService from './services/partLookupService.js';
import tecdocService from './services/tecdocService.js';

// Use Web Image Search instead of Gemini for images
const imageService = {
    searchVehicleImages,
    searchPartImages,
    clearSearchCache,
    getCacheStats
};

const app = express();
const PORT = process.env.PORT || 3001;

// ========================================
// TRUST PROXY CONFIGURATION
// ========================================
// Trust exactly 1 proxy hop (nginx). Using `true` causes
// ERR_ERL_PERMISSIVE_TRUST_PROXY in express-rate-limit v7+.
app.set('trust proxy', 1);

// ========================================
// SECURITY MIDDLEWARE (Applied First)
// ========================================

// Helmet security headers (production-grade security)
app.use(securityHeaders);

// Security logging for sensitive operations
app.use(securityLogger);

// Input sanitization (XSS prevention) - Applied in all environments
// Security Note: Sanitization must run in dev to catch injection issues early
app.use(sanitizeInput);
app.use(validateSqlInput);

// XSS prevention headers
app.use(preventXSS);

// Global rate limiting (all routes) - Applied in all environments
// Development uses a more lenient limit to avoid disrupting workflows
if (process.env.NODE_ENV === 'production') {
    app.use(globalRateLimit);
} else {
    // Development: higher limit (500 req/15min) to avoid dev disruption
    const devRateLimit = (await import('express-rate-limit')).default;
    app.use(devRateLimit({
        windowMs: 15 * 60 * 1000,
        max: 500,
        message: { success: false, error: 'Dev rate limit exceeded' },
        standardHeaders: true,
        legacyHeaders: false,
    }));
}

// ========================================
// CORS CONFIGURATION
// ========================================

// Parse allowed origins from environment (comma-separated)
const allowedOrigins = process.env.FRONTEND_URL
    ? process.env.FRONTEND_URL.split(',').map(url => url.trim())
    : ['http://localhost:5173'];

// CORS configuration for frontend (supports multiple origins for Vercel previews)
const corsOptions = process.env.NODE_ENV === 'production'
    ? productionCorsOptions
    : {
        origin: (origin, callback) => {
            // Allow requests with no origin (mobile apps, curl, etc.)
            if (!origin) return callback(null, true);

            // Check if origin matches allowed list or Vercel preview URLs
            const isAllowed = allowedOrigins.some(allowed => {
                if (allowed.includes('*')) {
                    // Handle wildcard patterns like *.vercel.app
                    const pattern = new RegExp('^' + allowed.replace(/\*/g, '.*') + '$');
                    return pattern.test(origin);
                }
                return allowed === origin;
            });

            if (isAllowed) {
                callback(null, true);
            } else {
                console.warn(`CORS blocked origin: ${origin}`);
                callback(null, true); // Allow in dev, change to callback(new Error('CORS')) in strict mode
            }
        },
        methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization'],
        credentials: true,
    };

// Middleware
app.use(cors(corsOptions));
app.use(express.json({ limit: '50mb' })); // Increase limit for image uploads
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// ========================================
// AUTHENTICATION ROUTES
// ========================================

// Mount authentication routes
app.use('/api/auth', authRoutes);

// ========================================
// API ROUTES (with VIN rate limiting)
// ========================================

// Apply VIN decode rate limiting to VIN endpoints
app.use('/api/vin', vinDecodeRateLimit);
app.use('/api/vehicle', vinDecodeRateLimit);
app.use('/api/tecdoc', vinDecodeRateLimit);

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        message: 'German Car Medic API is running',
        timestamp: new Date().toISOString(),
    });
});

// Placeholder routes (to be implemented)
// GET decode by path param
app.get('/api/vin/decode/:vin', async (req, res, next) => {
    const { vin } = req.params;

    try {
        const validation = vinUtils.validateVIN(vin);
        if (!validation.valid) {
            return res.status(400).json({
                error: 'Invalid VIN',
                message: validation.error,
                vinInput: vin
            });
        }

        // Call multi-provider VIN service (NHTSA primary, Vincario fallback)
        const apiResponse = await multiProviderVinService.decodeVIN(validation.vin);
        const vehicle = multiProviderVinService.parseVehicleData(apiResponse);

        // Enrich vehicle data with AI predictions for missing fields (cached for consistency)
        const enrichedVehicle = await vehicleEnrichmentService.enrichVehicleData(vehicle);

        return res.json({
            success: true,
            vehicle: enrichedVehicle,
            enrichmentApplied: enrichedVehicle._enriched || false
        });
    } catch (err) {
        // VINDecodeError from service exposes statusCode
        if (err && err.name === 'VINDecodeError') {
            return res.status(err.statusCode || 500).json({ error: err.code || 'API_ERROR', message: err.message });
        }

        // Unexpected error
        console.error('Error decoding VIN:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to decode VIN' });
    }
});

// POST decode by JSON body { vin: '...' }
app.post('/api/vin/decode', async (req, res) => {
    const { vin, enrich = false } = req.body || {};

    try {
        const validation = vinUtils.validateVIN(vin);
        if (!validation.valid) {
            return res.status(400).json({
                error: 'Invalid VIN',
                message: validation.error,
                vinInput: vin
            });
        }

        // Decode VIN from multi-provider service
        const vehicle = await multiProviderVinService.decodeVIN(validation.vin);
        console.log('VIN decoded successfully:', { make: vehicle.make, model: vehicle.model, year: vehicle.year });

        // Skip enrichment by default for faster response (can be enabled with enrich=true)
        if (enrich) {
            // Enrich vehicle data with AI predictions for missing fields (cached for consistency)
            const enrichedVehicle = await vehicleEnrichmentService.enrichVehicleData(vehicle);
            console.log('Vehicle enriched:', { enriched: enrichedVehicle._enriched, source: enrichedVehicle._enrichedFrom });

            return res.json({
                success: true,
                vehicle: enrichedVehicle,
                enrichmentApplied: enrichedVehicle._enriched || false
            });
        }

        return res.json({
            success: true,
            vehicle,
            enrichmentApplied: false
        });
    } catch (err) {
        if (err && err.name === 'VINDecodeError') {
            return res.status(err.statusCode || 500).json({ error: err.code || 'API_ERROR', message: err.message });
        }

        console.error('Error decoding VIN:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to decode VIN' });
    }
});

app.get('/api/vehicle/images/:vin', async (req, res) => {
    const { vin } = req.params;
    const { refresh } = req.query;

    try {
        // First validate the VIN
        const validation = vinUtils.validateVIN(vin);
        if (!validation.valid) {
            return res.status(400).json({
                error: 'Invalid VIN',
                message: validation.error,
                vinInput: vin
            });
        }

        // Decode VIN to get vehicle data
        const vehicleData = await multiProviderVinService.decodeVIN(validation.vin);

        // Enrich vehicle data with AI predictions for missing fields (cached for consistency)
        const enrichedVehicle = await vehicleEnrichmentService.enrichVehicleData(vehicleData);

        // Check for minimum required data
        if (!enrichedVehicle.make || !enrichedVehicle.model || !enrichedVehicle.year) {
            return res.status(400).json({
                error: 'INSUFFICIENT_DATA',
                message: 'Vehicle data incomplete - make, model, and year required for image search'
            });
        }

        // Search for vehicle images using web search APIs with enriched data
        const imageResults = await imageService.searchVehicleImages(enrichedVehicle);

        return res.json({
            success: true,
            vin: validation.vin,
            vehicle: {
                make: enrichedVehicle.make,
                model: enrichedVehicle.model,
                year: enrichedVehicle.year,
                trim: enrichedVehicle.trim
            },
            source: 'web-search',
            enrichmentApplied: enrichedVehicle._enriched || false,
            ...imageResults
        });

    } catch (err) {
        // Handle VIN decode errors
        if (err && err.name === 'VINDecodeError') {
            return res.status(err.statusCode || 500).json({ error: err.code || 'VIN_DECODE_ERROR', message: err.message });
        }

        // Handle image search errors
        if (err && err.name === 'VehicleImageSearchError') {
            return res.status(err.statusCode || 500).json({ error: err.code || 'IMAGE_SEARCH_ERROR', message: err.message });
        }

        // Unexpected error
        console.error('Error generating vehicle images:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to generate vehicle images' });
    }
});

// POST vehicle images endpoint (accepts vehicle data directly)
app.post('/api/vehicle/images', async (req, res) => {
    const { vehicleData, options = {} } = req.body || {};

    try {
        // Validate required vehicle data
        if (!vehicleData || !vehicleData.make || !vehicleData.model || !vehicleData.year) {
            return res.status(400).json({
                error: 'INVALID_DATA',
                message: 'Vehicle data with make, model, and year is required'
            });
        }

        // Search for vehicle images using web search APIs
        const imageResults = await imageService.searchVehicleImages(vehicleData);

        return res.json({
            success: true,
            vehicle: vehicleData,
            source: 'web-search',
            options,
            ...imageResults
        });

    } catch (err) {
        // Handle image search errors
        if (err && err.name === 'VehicleImageSearchError') {
            return res.status(err.status || 500).json({
                error: err.code || 'IMAGE_SEARCH_ERROR',
                message: err.message
            });
        }

        // Unexpected error
        console.error('Error searching vehicle images:', err);
        return res.status(500).json({
            error: 'INTERNAL_ERROR',
            message: 'Failed to search vehicle images'
        });
    }
});

// Parts image search endpoint
app.get('/api/parts/images', async (req, res) => {
    const { partName, vin, make, model, year } = req.query;

    try {
        let vehicleData;

        // Get vehicle data from VIN or query params
        if (vin) {
            // Validate and decode VIN
            const validation = vinUtils.validateVIN(vin);
            if (!validation.valid) {
                return res.status(400).json({
                    error: 'INVALID_VIN',
                    message: validation.error
                });
            }

            // Decode VIN to get vehicle data
            vehicleData = await multiProviderVinService.decodeVIN(validation.vin);
        } else if (make && model && year) {
            // Use provided vehicle data
            vehicleData = { make, model, year: parseInt(year) };
        } else {
            return res.status(400).json({
                error: 'INVALID_REQUEST',
                message: 'Either VIN or vehicle data (make, model, year) is required'
            });
        }

        // Validate part name
        if (!partName || typeof partName !== 'string' || partName.trim().length === 0) {
            return res.status(400).json({
                error: 'INVALID_PART_NAME',
                message: 'Part name is required and must be a non-empty string'
            });
        }

        // Search for part images
        const partResults = await imageService.searchPartImages(partName.trim(), vehicleData);

        return res.json({
            success: true,
            partName: partName.trim(),
            vehicle: {
                make: vehicleData.make,
                model: vehicleData.model,
                year: vehicleData.year
            },
            source: 'web-search',
            ...partResults
        });

    } catch (err) {
        // Handle VIN decode errors
        if (err && err.name === 'VINDecodeError') {
            return res.status(err.statusCode || 500).json({
                error: err.code || 'VIN_DECODE_ERROR',
                message: err.message
            });
        }

        // Handle part search errors
        if (err && err.name === 'PartImageSearchError') {
            return res.status(err.status || 500).json({
                error: err.code || 'PART_SEARCH_ERROR',
                message: err.message
            });
        }

        // Unexpected error
        console.error('Error searching part images:', err);
        return res.status(500).json({
            error: 'INTERNAL_ERROR',
            message: 'Failed to search part images'
        });
    }
});

// Cache status endpoint
app.get('/api/cache/images', (req, res) => {
    try {
        const stats = imageService.getCacheStats();
        return res.json({
            success: true,
            cache: stats,
            timestamp: new Date().toISOString()
        });
    } catch (err) {
        console.error('Error getting cache stats:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to get cache stats' });
    }
});

// Clear cache endpoint
app.delete('/api/cache/images', (req, res) => {
    try {
        imageService.clearSearchCache();
        return res.json({
            success: true,
            message: 'Cache cleared successfully',
            timestamp: new Date().toISOString()
        });
    } catch (err) {
        console.error('Error clearing cache:', err);
        return res.status(500).json({
            error: 'INTERNAL_ERROR',
            message: 'Failed to clear cache'
        });
    }
});

// Clean expired cache entries endpoint
app.post('/api/cache/images/clean', (req, res) => {
    try {
        const statsBefore = imageService.getCacheStats();
        imageService.cleanCache();
        const statsAfter = imageService.getCacheStats();

        return res.json({
            success: true,
            cleaned: statsBefore.expired,
            before: statsBefore,
            after: statsAfter,
            timestamp: new Date().toISOString()
        });
    } catch (err) {
        console.error('Error cleaning cache:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to clean cache' });
    }
});

app.get('/api/vehicle/summary/:vin', async (req, res) => {
    const { vin } = req.params;

    try {
        // Validate VIN
        const validation = vinUtils.validateVIN(vin);
        if (!validation.valid) {
            return res.status(400).json({ error: 'Invalid VIN', message: validation.error });
        }

        // Decode VIN to get vehicle data
        const vehicleData = await multiProviderVinService.decodeVIN(validation.vin);

        // Enrich vehicle data with AI predictions for missing fields (cached for consistency)
        const enrichedVehicle = await vehicleEnrichmentService.enrichVehicleData(vehicleData);
        console.log('Vehicle enriched for summary:', { enriched: enrichedVehicle._enriched, source: enrichedVehicle._enrichedFrom });

        // Generate summary using Gemini with enriched data
        const summary = await geminiAiService.generateVehicleSummary(enrichedVehicle);

        return res.json({
            success: true,
            vin: validation.vin,
            vehicle: {
                make: enrichedVehicle.make,
                model: enrichedVehicle.model,
                year: enrichedVehicle.year,
                engine: enrichedVehicle.engine,
                bodyType: enrichedVehicle.bodyType,
                trim: enrichedVehicle.trim
            },
            enrichmentApplied: enrichedVehicle._enriched || false,
            ...summary
        });
    } catch (err) {
        if (err && err.name === 'VINDecodeError') {
            return res.status(err.statusCode || 500).json({ error: err.code || 'VIN_DECODE_ERROR', message: err.message });
        }

        if (err && err.name === 'GeminiAiError') {
            return res.status(err.statusCode || 500).json({ error: err.code || 'AI_ERROR', message: err.message });
        }

        console.error('Error generating vehicle summary:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to generate vehicle summary' });
    }
});

app.post('/api/parts/identify', async (req, res) => {
    const { partName, vehicleData } = req.body || {};

    try {
        if (!partName) {
            return res.status(400).json({ error: 'MISSING_PARAM', message: 'partName is required' });
        }

        // Generate part information using Gemini
        const partInfo = await geminiAiService.identifyPart({ partName, vehicleData });

        return res.json({
            success: true,
            partName,
            vehicle: vehicleData || null,
            ...partInfo
        });
    } catch (err) {
        if (err && err.name === 'GeminiAiError') {
            return res.status(err.statusCode || 500).json({ error: err.code || 'AI_ERROR', message: err.message });
        }

        console.error('Error identifying part:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to identify part' });
    }
});

app.get('/api/parts/spare-parts/:vin', async (req, res) => {
    const { vin } = req.params;
    const { system } = req.query;

    try {
        // Validate VIN
        const validation = vinUtils.validateVIN(vin);
        if (!validation.valid) {
            return res.status(400).json({ error: 'Invalid VIN', message: validation.error });
        }

        // Decode VIN to get vehicle data
        const vehicleData = await multiProviderVinService.decodeVIN(validation.vin);

        // Enrich vehicle data with AI predictions for missing fields (cached for consistency)
        const enrichedVehicle = await vehicleEnrichmentService.enrichVehicleData(vehicleData);

        // Generate spare parts recommendations using Gemini with enriched data
        const sparePartsSummary = await geminiAiService.generateSparePartsSummary(enrichedVehicle, system || 'general');

        return res.json({
            success: true,
            vin: validation.vin,
            vehicle: {
                make: enrichedVehicle.make,
                model: enrichedVehicle.model,
                year: enrichedVehicle.year
            },
            enrichmentApplied: enrichedVehicle._enriched || false,
            ...sparePartsSummary
        });
    } catch (err) {
        if (err && err.name === 'VINDecodeError') {
            return res.status(err.statusCode || 500).json({ error: err.code || 'VIN_DECODE_ERROR', message: err.message });
        }

        if (err && err.name === 'GeminiAiError') {
            return res.status(err.statusCode || 500).json({ error: err.code || 'AI_ERROR', message: err.message });
        }

        console.error('Error generating spare parts summary:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to generate spare parts summary' });
    }
});

app.post('/api/parts/spare-parts', async (req, res) => {
    const { vehicleData, system } = req.body || {};

    try {
        if (!vehicleData || !vehicleData.make || !vehicleData.model || !vehicleData.year) {
            return res.status(400).json({
                error: 'MISSING_DATA',
                message: 'vehicleData with make, model, and year is required'
            });
        }

        // Generate spare parts recommendations using Gemini
        const sparePartsSummary = await geminiAiService.generateSparePartsSummary(vehicleData, system || 'general');

        return res.json({
            success: true,
            vehicle: {
                make: vehicleData.make,
                model: vehicleData.model,
                year: vehicleData.year
            },
            ...sparePartsSummary
        });
    } catch (err) {
        if (err && err.name === 'GeminiAiError') {
            return res.status(err.statusCode || 500).json({ error: err.code || 'AI_ERROR', message: err.message });
        }

        console.error('Error generating spare parts summary:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to generate spare parts summary' });
    }
});

// Part details via 2-tier lookup: Auto Parts Catalog API → SerpAPI → "not found"
app.post('/api/parts/details', async (req, res) => {
    const { partName, partId, vehicleData } = req.body || {};

    try {
        if (!partName) {
            return res.status(400).json({
                error: 'MISSING_PARAM',
                message: 'partName is required'
            });
        }

        const vehicle = vehicleData || null;
        console.log(`🔧 Part lookup: "${partName}"${vehicle ? ` for ${vehicle.year || ''} ${vehicle.make || ''} ${vehicle.model || ''}`.trim() : ''}`);

        // Use Gemini AI directly for part identification (no SerpAPI)
        let aiDescription = '';
        let aiFunction = '';
        let aiSymptoms = [];
        let resolvedPartName = partName;

        try {
            const aiResult = await geminiAiService.identifyPart({
                partName,
                vehicleData: vehicle,
            });

            if (aiResult.success && aiResult.information) {
                const info = aiResult.information;

                // Parse structured sections from AI response
                const lines = info.split('\n').map(l => l.trim()).filter(Boolean);
                const sections = { description: [], function: [], symptoms: [] };
                let currentSection = 'description';

                for (const line of lines) {
                    if (/\*\*.*function|purpose/i.test(line) || /^\d+\.\s*(part\s+)?function/i.test(line)) {
                        currentSection = 'function';
                        const inlineContent = line.replace(/^\*\*[^*]+\*\*:?\s*/, '').replace(/^\d+\.\s*[^:]+:\s*/, '').trim();
                        if (inlineContent) sections.function.push(inlineContent);
                        continue;
                    }
                    if (/\*\*.*symptom|failure|issue/i.test(line) || /^\d+\.\s*symptom/i.test(line)) {
                        currentSection = 'symptoms';
                        continue;
                    }
                    if (/\*\*.*component|subpart|main/i.test(line) || /^\d+\.\s*main\s+component/i.test(line)) {
                        currentSection = 'description';
                        continue;
                    }
                    if (/\*\*.*(?:oem|part\s*number|compatible|alternative|aftermarket|installation|service\s+life|maintenance)/i.test(line)
                        || /^\d+\.\s*(?:common\s+oem|expected\s+service|compatible|installation)/i.test(line)) {
                        currentSection = 'description';
                        continue;
                    }

                    const cleaned = line.replace(/^[•\-\*]\s+/, '').replace(/^\d+\.\s+/, '').trim();
                    if (cleaned) {
                        sections[currentSection].push(cleaned);
                    }
                }

                if (sections.description.length > 0 || sections.function.length > 0) {
                    const allContent = [...sections.description, ...sections.function];
                    aiDescription = allContent.join('\n');
                }
                if (sections.function.length > 0) {
                    aiFunction = sections.function.join('\n');
                }
                if (sections.symptoms.length > 0) {
                    aiSymptoms = sections.symptoms.map(s => s.replace(/^\*\*[^*]+\*\*:?\s*/, '').trim());
                }

                // If parsing didn't extract structured sections, use the full AI text
                if (!aiFunction && !aiSymptoms.length) {
                    aiDescription = info;
                }

                resolvedPartName = aiResult.partName || partName;
                console.log(`🤖 Gemini AI lookup successful for "${resolvedPartName}"`);
            } else {
                return res.status(404).json({
                    success: false,
                    error: 'PART_NOT_FOUND',
                    message: `No data found for "${partName}". Try a different part number or check the format.`,
                    partName
                });
            }
        } catch (aiErr) {
            console.error(`❌ Gemini AI lookup failed: ${aiErr.message}`);
            return res.status(404).json({
                success: false,
                error: 'PART_NOT_FOUND',
                message: `Could not look up "${partName}". Please try again.`,
                partName
            });
        }

        return res.json({
            success: true,
            partId: partId || partName.toLowerCase().replace(/\s+/g, '-'),
            partName: resolvedPartName,
            vehicle: vehicle,
            image: null,
            description: aiDescription,
            function: aiFunction || null,
            symptoms: aiSymptoms,
            spareParts: [],
            partNumber: partName,
            supplier: null,
            source: 'gemini-ai',
            searchResults: null,
            imageSource: 'none',
            descriptionSource: 'gemini-ai',
            generatedAt: new Date().toISOString()
        });

    } catch (err) {
        console.error('Error fetching part details:', err);
        return res.status(500).json({
            error: 'INTERNAL_ERROR',
            message: 'Failed to fetch part details'
        });
    }
});

// ==================== PART SCANNING ENDPOINTS ====================

// Scan and analyze a spare part from image
app.post('/api/parts/scan', async (req, res) => {
    try {
        const { imageBase64, mimeType, vehicleContext } = req.body || {};

        // Validate required fields
        if (!imageBase64 || !mimeType) {
            return res.status(400).json({
                error: 'MISSING_DATA',
                message: 'imageBase64 and mimeType are required'
            });
        }

        // Validate image
        const validation = geminiVisionService.validateImage(imageBase64, mimeType);
        if (!validation.valid) {
            return res.status(400).json({
                error: 'INVALID_IMAGE',
                message: validation.error
            });
        }

        // Analyze the part image without vehicle context bias
        const analysis = await geminiVisionService.analyzePartImage(
            imageBase64,
            mimeType
        );

        // Return analysis with separate vehicle context for display only
        return res.json({
            success: true,
            ...analysis,
            vehicleContext: vehicleContext || null // For display only, not used in analysis
        });

    } catch (err) {
        if (err && err.name === 'GeminiVisionError') {
            return res.status(err.statusCode || 500).json({
                error: err.code || 'VISION_ERROR',
                message: err.message
            });
        }

        console.error('Error scanning part:', err);
        return res.status(500).json({
            error: 'INTERNAL_ERROR',
            message: 'Failed to analyze part image'
        });
    }
});

// Ask a specific question about a part image
app.post('/api/parts/scan/question', async (req, res) => {
    try {
        const { imageBase64, mimeType, question, vehicleContext } = req.body || {};

        // Validate required fields
        if (!imageBase64 || !mimeType || !question) {
            return res.status(400).json({
                error: 'MISSING_DATA',
                message: 'imageBase64, mimeType, and question are required'
            });
        }

        // Validate image
        const validation = geminiVisionService.validateImage(imageBase64, mimeType);
        if (!validation.valid) {
            return res.status(400).json({
                error: 'INVALID_IMAGE',
                message: validation.error
            });
        }

        // Validate question
        if (typeof question !== 'string' || question.trim().length < 3) {
            return res.status(400).json({
                error: 'INVALID_QUESTION',
                message: 'Question must be at least 3 characters long'
            });
        }

        // Ask the question about the part without vehicle context bias
        const response = await geminiVisionService.askPartQuestion(
            imageBase64,
            mimeType,
            question.trim()
        );

        // Return response with separate vehicle context for display only
        return res.json({
            success: true,
            ...response,
            vehicleContext: vehicleContext || null // For display only, not used in analysis
        });

    } catch (err) {
        if (err && err.name === 'GeminiVisionError') {
            return res.status(err.statusCode || 500).json({
                error: err.code || 'VISION_ERROR',
                message: err.message
            });
        }

        console.error('Error answering part question:', err);
        return res.status(500).json({
            error: 'INTERNAL_ERROR',
            message: 'Failed to answer question about part'
        });
    }
});

// Compare multiple part images
app.post('/api/parts/scan/compare', async (req, res) => {
    try {
        const { images, comparisonType, vehicleContext } = req.body || {};

        // Validate required fields
        if (!images || !Array.isArray(images)) {
            return res.status(400).json({
                error: 'MISSING_DATA',
                message: 'images array is required'
            });
        }

        if (images.length < 2 || images.length > 4) {
            return res.status(400).json({
                error: 'INVALID_INPUT',
                message: 'Must provide 2-4 images for comparison'
            });
        }

        // Validate each image
        for (let i = 0; i < images.length; i++) {
            const img = images[i];
            if (!img.imageBase64 || !img.mimeType) {
                return res.status(400).json({
                    error: 'INVALID_IMAGE_DATA',
                    message: `Image ${i + 1} is missing imageBase64 or mimeType`
                });
            }

            const validation = geminiVisionService.validateImage(img.imageBase64, img.mimeType);
            if (!validation.valid) {
                return res.status(400).json({
                    error: 'INVALID_IMAGE',
                    message: `Image ${i + 1}: ${validation.error}`
                });
            }
        }

        // Compare the parts without vehicle context bias
        const comparison = await geminiVisionService.comparePartImages(
            images,
            comparisonType || 'general'
        );

        // Return comparison with separate vehicle context for display only
        return res.json({
            success: true,
            ...comparison,
            vehicleContext: vehicleContext || null // For display only, not used in analysis
        });

    } catch (err) {
        if (err && err.name === 'GeminiVisionError') {
            return res.status(err.statusCode || 500).json({
                error: err.code || 'VISION_ERROR',
                message: err.message
            });
        }

        console.error('Error comparing parts:', err);
        return res.status(500).json({
            error: 'INTERNAL_ERROR',
            message: 'Failed to compare part images'
        });
    }
});

// Detect part numbers and markings in an image
app.post('/api/parts/scan/markings', async (req, res) => {
    try {
        const { imageBase64, mimeType } = req.body || {};

        // Validate required fields
        if (!imageBase64 || !mimeType) {
            return res.status(400).json({
                error: 'MISSING_DATA',
                message: 'imageBase64 and mimeType are required'
            });
        }

        // Validate image
        const validation = geminiVisionService.validateImage(imageBase64, mimeType);
        if (!validation.valid) {
            return res.status(400).json({
                error: 'INVALID_IMAGE',
                message: validation.error
            });
        }

        // Detect markings
        const markings = await geminiVisionService.detectPartMarkings(imageBase64, mimeType);

        return res.json({
            success: true,
            ...markings
        });

    } catch (err) {
        if (err && err.name === 'GeminiVisionError') {
            return res.status(err.statusCode || 500).json({
                error: err.code || 'VISION_ERROR',
                message: err.message
            });
        }

        console.error('Error detecting markings:', err);
        return res.status(500).json({
            error: 'INTERNAL_ERROR',
            message: 'Failed to detect part markings'
        });
    }
});

// Assess part condition and provide replacement recommendations
app.post('/api/parts/scan/condition', async (req, res) => {
    try {
        const { imageBase64, mimeType, vehicleContext } = req.body || {};

        // Validate required fields
        if (!imageBase64 || !mimeType) {
            return res.status(400).json({
                error: 'MISSING_DATA',
                message: 'imageBase64 and mimeType are required'
            });
        }

        // Validate image
        const validation = geminiVisionService.validateImage(imageBase64, mimeType);
        if (!validation.valid) {
            return res.status(400).json({
                error: 'INVALID_IMAGE',
                message: validation.error
            });
        }

        // Assess part condition without vehicle context bias
        const assessment = await geminiVisionService.assessPartCondition(
            imageBase64,
            mimeType
        );

        // Return assessment with separate vehicle context for display only
        return res.json({
            success: true,
            ...assessment,
            vehicleContext: vehicleContext || null // For display only, not used in analysis
        });

    } catch (err) {
        if (err && err.name === 'GeminiVisionError') {
            return res.status(err.statusCode || 500).json({
                error: err.code || 'VISION_ERROR',
                message: err.message
            });
        }

        console.error('Error assessing condition:', err);
        return res.status(500).json({
            error: 'INTERNAL_ERROR',
            message: 'Failed to assess part condition'
        });
    }
});

// ==================== END PART SCANNING ENDPOINTS ====================

// ==================== AI CHAT ENDPOINT ====================

/**
 * POST /api/ai/chat — General AI chat for mechanics
 * Accepts a free-form message with optional vehicle context
 * Body: { message: string, vehicleContext?: { make, model, year, vin } }
 */
app.post('/api/ai/chat', async (req, res) => {
    try {
        const { message, vehicleContext } = req.body;

        if (!message || typeof message !== 'string' || message.trim().length === 0) {
            return res.status(400).json({
                error: 'MISSING_MESSAGE',
                message: 'A non-empty message is required',
            });
        }

        if (message.trim().length > 2000) {
            return res.status(400).json({
                error: 'MESSAGE_TOO_LONG',
                message: 'Message must be under 2000 characters',
            });
        }

        // Build a prompt with optional vehicle context
        let prompt = message.trim();
        if (vehicleContext) {
            const parts = [];
            if (vehicleContext.make) parts.push(vehicleContext.make);
            if (vehicleContext.model) parts.push(vehicleContext.model);
            if (vehicleContext.year) parts.push(`(${vehicleContext.year})`);
            if (vehicleContext.vin) parts.push(`VIN: ${vehicleContext.vin}`);
            if (parts.length > 0) {
                prompt = `Vehicle context: ${parts.join(' ')}.\n\nUser question: ${prompt}`;
            }
        }

        const response = await geminiAiService.generateResponse(prompt);

        return res.json({
            success: true,
            response,
            timestamp: new Date().toISOString(),
        });
    } catch (err) {
        console.error('AI chat error:', err);
        return res.status(500).json({
            error: 'AI_CHAT_FAILED',
            message: err.message || 'Failed to generate AI response',
        });
    }
});

// ==================== END AI CHAT ENDPOINT ====================

// ==================== TECDOC VIN-TO-PARTS ENDPOINTS ====================

// Full VIN-to-Parts chain (decode → model types → parts)
app.get('/api/tecdoc/vin-to-parts/:vin', async (req, res) => {
    const { vin } = req.params;

    try {
        const validation = vinUtils.validateVIN(vin);
        if (!validation.valid) {
            return res.status(400).json({ error: 'Invalid VIN', message: validation.error });
        }

        const result = await tecdocService.vinToParts(validation.vin);
        return res.json({ success: true, ...result });
    } catch (err) {
        if (err && err.name === 'TecDocError') {
            return res.status(err.statusCode || 500).json({ error: 'TECDOC_ERROR', message: err.message });
        }
        console.error('Error in VIN-to-parts:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to lookup parts by VIN' });
    }
});

// Step 1: Decode VIN via TecDoc
app.get('/api/tecdoc/vin/decode/:vin', async (req, res) => {
    const { vin } = req.params;

    try {
        const validation = vinUtils.validateVIN(vin);
        if (!validation.valid) {
            return res.status(400).json({ error: 'Invalid VIN', message: validation.error });
        }

        const result = await tecdocService.decodeVin(validation.vin);
        return res.json({ success: true, ...result });
    } catch (err) {
        if (err && err.name === 'TecDocError') {
            return res.status(err.statusCode || 500).json({ error: 'TECDOC_ERROR', message: err.message });
        }
        console.error('Error decoding VIN via TecDoc:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to decode VIN' });
    }
});

// Step 2: Get model types by modelId
app.get('/api/tecdoc/model-types/:modelId', async (req, res) => {
    const { modelId } = req.params;

    try {
        const result = await tecdocService.getModelTypes(modelId);
        return res.json({ success: true, ...result });
    } catch (err) {
        if (err && err.name === 'TecDocError') {
            return res.status(err.statusCode || 500).json({ error: 'TECDOC_ERROR', message: err.message });
        }
        console.error('Error getting model types:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to get model types' });
    }
});

// Step 3: Get parts by vehicleId
app.get('/api/tecdoc/vehicle-parts/:vehicleId', async (req, res) => {
    const { vehicleId } = req.params;

    try {
        const result = await tecdocService.getVehicleParts(vehicleId);
        return res.json({ success: true, ...result });
    } catch (err) {
        if (err && err.name === 'TecDocError') {
            return res.status(err.statusCode || 500).json({ error: 'TECDOC_ERROR', message: err.message });
        }
        console.error('Error getting vehicle parts:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to get vehicle parts' });
    }
});

// TecDoc part description via Gemini AI
app.get('/api/tecdoc/part-description', async (req, res) => {
    const { partName, make, model, year } = req.query;
    if (!partName) {
        return res.status(400).json({ error: 'MISSING_PARAM', message: 'partName query parameter is required' });
    }
    try {
        const vehicleData = (make || model || year) ? { make, model, year } : null;
        const description = await geminiAiService.generatePartDescription(partName, vehicleData);
        return res.json({ success: true, partName, description });
    } catch (err) {
        if (err && err.name === 'GeminiAiError') {
            return res.status(err.statusCode || 500).json({ error: err.code, message: err.message });
        }
        console.error('Error generating part description:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to generate part description' });
    }
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Not Found',
        message: `Route ${req.method} ${req.path} not found`,
    });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Server error:', err);
    res.status(500).json({
        error: 'Internal Server Error',
        message: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong',
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`🚗 German Car Medic API running on http://localhost:${PORT}`);
    console.log(`📋 Health check: http://localhost:${PORT}/api/health`);
    console.log(`🔧 Environment: ${process.env.NODE_ENV || 'development'}`);
});
