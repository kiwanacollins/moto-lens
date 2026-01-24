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

// Services
import autodevService from './services/autodevService.js';
import vinUtils from './utils/vinValidator.js';
import geminiAiService from './services/geminiAiService.js';
import vehicleEnrichmentService from './services/vehicleEnrichmentService.js';
import {
    searchVehicleImages,
    searchPartImages,
    clearSearchCache,
    getCacheStats
} from './services/webImageSearchService.js';

// Use Web Image Search instead of Gemini for images
const imageService = {
    searchVehicleImages,
    searchPartImages,
    clearSearchCache,
    getCacheStats
};

const app = express();
const PORT = process.env.PORT || 3001;

// CORS configuration for frontend
const corsOptions = {
    origin: process.env.FRONTEND_URL || 'http://localhost:5173',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
};

// Middleware
app.use(cors(corsOptions));
app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        message: 'MotoLens API is running',
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
            return res.status(400).json({ error: 'Invalid VIN', message: validation.error });
        }

        // Call Auto.dev service
        const apiResponse = await autodevService.decodeVIN(validation.vin);
        const vehicle = autodevService.parseVehicleData(apiResponse);

        return res.json({ success: true, vehicle });
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
    const { vin } = req.body || {};

    try {
        const validation = vinUtils.validateVIN(vin);
        if (!validation.valid) {
            return res.status(400).json({ error: 'Invalid VIN', message: validation.error });
        }

        // Decode VIN from external API
        const apiResponse = await autodevService.decodeVIN(validation.vin);
        const vehicle = autodevService.parseVehicleData(apiResponse);

        // Enrich vehicle data with AI predictions for missing fields
        console.log('Original vehicle data:', vehicle);
        const enrichedVehicle = await vehicleEnrichmentService.enrichVehicleData(vehicle);
        console.log('Enriched vehicle data:', enrichedVehicle);

        return res.json({
            success: true,
            vehicle: enrichedVehicle,
            enrichmentApplied: enrichedVehicle._enriched || false
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
            return res.status(400).json({ error: 'Invalid VIN', message: validation.error });
        }

        // Decode VIN to get vehicle data
        const apiResponse = await autodevService.decodeVIN(validation.vin);
        const vehicle = autodevService.parseVehicleData(apiResponse);

        // Check for minimum required data
        if (!vehicle.make || !vehicle.model || !vehicle.year) {
            return res.status(400).json({
                error: 'INSUFFICIENT_DATA',
                message: 'Vehicle data incomplete - make, model, and year required for image search'
            });
        }

        // Search for vehicle images using web search APIs
        const imageResults = await imageService.searchVehicleImages(vehicle);

        return res.json({
            success: true,
            vin: validation.vin,
            vehicle: {
                make: vehicle.make,
                model: vehicle.model,
                year: vehicle.year,
                trim: vehicle.trim
            },
            source: 'web-search',
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
            const apiResponse = await autodevService.decodeVIN(validation.vin);
            vehicleData = autodevService.parseVehicleData(apiResponse);
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
        const apiResponse = await autodevService.decodeVIN(validation.vin);
        const vehicleData = autodevService.parseVehicleData(apiResponse);

        // Generate summary using Gemini
        const summary = await geminiAiService.generateVehicleSummary(vehicleData);

        return res.json({
            success: true,
            vin: validation.vin,
            vehicle: {
                make: vehicleData.make,
                model: vehicleData.model,
                year: vehicleData.year,
                engine: vehicleData.engine,
                bodyType: vehicleData.bodyType,
                trim: vehicleData.trim
            },
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
        const apiResponse = await autodevService.decodeVIN(validation.vin);
        const vehicleData = autodevService.parseVehicleData(apiResponse);

        // Generate spare parts recommendations using Gemini
        const sparePartsSummary = await geminiAiService.generateSparePartsSummary(vehicleData, system || 'general');

        return res.json({
            success: true,
            vin: validation.vin,
            vehicle: {
                make: vehicleData.make,
                model: vehicleData.model,
                year: vehicleData.year
            },
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
    console.log(`🚗 MotoLens API running on http://localhost:${PORT}`);
    console.log(`📋 Health check: http://localhost:${PORT}/api/health`);
    console.log(`🔧 Environment: ${process.env.NODE_ENV || 'development'}`);
});
