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
app.get('/api/vin/decode/:vin', (req, res) => {
    const { vin } = req.params;

    // VIN validation (17 characters, alphanumeric)
    if (!vin || vin.length !== 17) {
        return res.status(400).json({
            error: 'Invalid VIN',
            message: 'VIN must be exactly 17 characters',
        });
    }

    // Placeholder response - will be replaced with Auto.dev API call
    res.json({
        message: 'VIN decode endpoint ready',
        vin: vin.toUpperCase(),
        note: 'Auto.dev API integration pending',
    });
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
