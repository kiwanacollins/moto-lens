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

        const apiResponse = await autodevService.decodeVIN(validation.vin);
        const vehicle = autodevService.parseVehicleData(apiResponse);

        return res.json({ success: true, vehicle });
    } catch (err) {
        if (err && err.name === 'VINDecodeError') {
            return res.status(err.statusCode || 500).json({ error: err.code || 'API_ERROR', message: err.message });
        }

        console.error('Error decoding VIN:', err);
        return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Failed to decode VIN' });
    }
});

app.get('/api/vehicle/images/:vin', (req, res) => {
    const { vin } = req.params;

    // Placeholder response - will be replaced with Gemini/Imagen call
    res.json({
        message: 'Vehicle images endpoint ready',
        vin: vin.toUpperCase(),
        note: 'Gemini/Imagen integration pending',
    });
});

app.get('/api/vehicle/summary/:vin', (req, res) => {
    const { vin } = req.params;

    // Placeholder response - will be replaced with Gemini call
    res.json({
        message: 'Vehicle summary endpoint ready',
        vin: vin.toUpperCase(),
        note: 'Gemini integration pending',
    });
});

app.post('/api/parts/identify', (req, res) => {
    const { partName, vehicleData } = req.body;

    // Placeholder response - will be replaced with Gemini call
    res.json({
        message: 'Part identification endpoint ready',
        partName,
        note: 'Gemini integration pending',
    });
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
