/**
 * Security Middleware for German Car Medic API
 *
 * Comprehensive security middleware including:
 * - Helmet.js security headers
 * - CORS configuration
 * - Rate limiting
 * - Input sanitization
 * - XSS prevention
 * - CSRF protection
 */

import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import { body, validationResult } from 'express-validator';
import crypto from 'crypto';

/**
 * Helmet Security Headers Configuration
 * Implements OWASP security best practices
 */
export const securityHeaders = helmet({
    // Content Security Policy
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            scriptSrc: ["'self'"],
            imgSrc: ["'self'", 'data:', 'https:'],
            connectSrc: ["'self'"],
            fontSrc: ["'self'"],
            objectSrc: ["'none'"],
            mediaSrc: ["'self'"],
            frameSrc: ["'none'"],
        },
    },

    // Cross-Origin Resource Policy
    crossOriginResourcePolicy: { policy: 'cross-origin' },

    // Cross-Origin Embedder Policy
    crossOriginEmbedderPolicy: false, // Set to true in production if needed

    // DNS Prefetch Control
    dnsPrefetchControl: { allow: false },

    // Expect-CT
    expectCt: {
        enforce: true,
        maxAge: 86400, // 24 hours
    },

    // Frameguard (prevent clickjacking)
    frameguard: { action: 'deny' },

    // Hide X-Powered-By header
    hidePoweredBy: true,

    // HTTP Strict Transport Security
    hsts: {
        maxAge: 31536000, // 1 year
        includeSubDomains: true,
        preload: true,
    },

    // IE No Open
    ieNoOpen: true,

    // No Sniff
    noSniff: true,

    // Origin Agent Cluster
    originAgentCluster: true,

    // Permitted Cross-Domain Policies
    permittedCrossDomainPolicies: { permittedPolicies: 'none' },

    // Referrer Policy
    referrerPolicy: { policy: 'strict-origin-when-cross-origin' },

    // X-XSS-Protection (legacy browsers)
    xssFilter: true,
});

/**
 * Production CORS Configuration
 * Strict origin validation for production environment
 */
export const productionCorsOptions = {
    origin: (origin, callback) => {
        const allowedOrigins = [
            process.env.FRONTEND_URL,
            process.env.MOBILE_APP_URL,
            'https://germancarmedic.com',
            'https://www.germancarmedic.com',
            'https://app.germancarmedic.com',
        ].filter(Boolean);

        // Allow requests with no origin (mobile apps, Postman, etc.)
        if (!origin) {
            return callback(null, true);
        }

        // Check if origin is in allowed list
        const isAllowed = allowedOrigins.some(allowed => {
            if (allowed.includes('*')) {
                const pattern = new RegExp('^' + allowed.replace(/\*/g, '.*') + '$');
                return pattern.test(origin);
            }
            return allowed === origin;
        });

        if (isAllowed) {
            callback(null, true);
        } else {
            console.warn(`CORS blocked origin: ${origin}`);
            callback(new Error('Not allowed by CORS'));
        }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'X-CSRF-Token'],
    credentials: true,
    maxAge: 86400, // 24 hours
};

/**
 * Rate Limiting Configurations
 */

// Global API rate limit (per IP)
export const globalRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 600, // 300 requests per 15 minutes
    message: {
        success: false,
        error: 'Too many requests',
        message: 'You have exceeded the rate limit. Please try again later.',
    },
    standardHeaders: true,
    legacyHeaders: false,
    // Skip successful requests from rate limiting
    skipSuccessfulRequests: false,
    // Skip failed requests from rate limiting
    skipFailedRequests: false,
});

// Strict rate limit for authentication endpoints
export const authRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 10, // 10 attempts per IP
    message: {
        success: false,
        error: 'Too many authentication attempts',
        message: 'Too many login attempts from this IP. Please try again after 15 minutes.',
    },
    standardHeaders: true,
    legacyHeaders: false,
});

// Registration rate limit (stricter)
export const registerRateLimit = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 3, // 3 registrations per IP per hour
    message: {
        success: false,
        error: 'Too many registration attempts',
        message: 'Too many accounts created from this IP. Please try again after 1 hour.',
    },
    standardHeaders: true,
    legacyHeaders: false,
});

// Password reset rate limit
export const passwordResetRateLimit = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 3, // 3 reset attempts per IP per hour
    message: {
        success: false,
        error: 'Too many password reset attempts',
        message: 'Too many password reset requests. Please try again after 1 hour.',
    },
    standardHeaders: true,
    legacyHeaders: false,
});

// Email verification rate limit
export const emailVerificationRateLimit = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 10, // 10 verification attempts per IP per hour
    message: {
        success: false,
        error: 'Too many verification attempts',
        message: 'Too many email verification requests. Please try again after 1 hour.',
    },
    standardHeaders: true,
    legacyHeaders: false,
});

// VIN decode rate limit (protect API quotas)
export const vinDecodeRateLimit = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 60, // 60 VIN/tecdoc requests per 15 minutes
    message: {
        success: false,
        error: 'Too many VIN decode requests',
        message: 'You have exceeded the VIN decode rate limit. Please try again later.',
    },
    standardHeaders: true,
    legacyHeaders: false,
});

/**
 * Input Sanitization Middleware
 * Removes potentially dangerous characters from input
 */
export const sanitizeInput = (req, res, next) => {
    try {
        // Sanitize body (can be replaced since it's mutable)
        if (req.body && typeof req.body === 'object') {
            req.body = sanitizeObject(req.body);
        }

        // Sanitize query parameters (in-place since query is read-only)
        if (req.query && typeof req.query === 'object') {
            sanitizeObjectInPlace(req.query);
        }

        // Sanitize URL parameters (in-place since params is read-only)
        if (req.params && typeof req.params === 'object') {
            sanitizeObjectInPlace(req.params);
        }

        next();
    } catch (error) {
        console.error('Input sanitization error:', error);
        res.status(400).json({
            success: false,
            error: 'Invalid input',
            message: 'Request contains invalid characters',
        });
    }
};

/**
 * Sanitize an object recursively
 * @param {Object} obj - Object to sanitize
 * @returns {Object} Sanitized object
 */
function sanitizeObject(obj) {
    if (typeof obj !== 'object' || obj === null) {
        return sanitizeValue(obj);
    }

    if (Array.isArray(obj)) {
        return obj.map(item => sanitizeObject(item));
    }

    const sanitized = {};
    for (const [key, value] of Object.entries(obj)) {
        // Sanitize key
        const cleanKey = sanitizeValue(key);

        // Sanitize value (recursively for objects)
        sanitized[cleanKey] = typeof value === 'object'
            ? sanitizeObject(value)
            : sanitizeValue(value);
    }

    return sanitized;
}

/**
 * Sanitize an object in-place (mutates the original object)
 * Used for read-only properties like req.query and req.params
 * @param {Object} obj - Object to sanitize in place
 */
function sanitizeObjectInPlace(obj) {
    if (typeof obj !== 'object' || obj === null) {
        return;
    }

    if (Array.isArray(obj)) {
        for (let i = 0; i < obj.length; i++) {
            if (typeof obj[i] === 'object') {
                sanitizeObjectInPlace(obj[i]);
            } else {
                obj[i] = sanitizeValue(obj[i]);
            }
        }
        return;
    }

    // Sanitize all values in place
    for (const key of Object.keys(obj)) {
        const value = obj[key];
        if (typeof value === 'object' && value !== null) {
            sanitizeObjectInPlace(value);
        } else {
            obj[key] = sanitizeValue(value);
        }
    }
}

/**
 * Sanitize a single value
 * @param {*} value - Value to sanitize
 * @returns {*} Sanitized value
 */
function sanitizeValue(value) {
    if (typeof value !== 'string') {
        return value;
    }

    // Remove potentially dangerous HTML/script tags
    let sanitized = value
        .replace(/<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, '')
        .replace(/<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>/gi, '')
        .replace(/on\w+\s*=\s*["'][^"']*["']/gi, ''); // Remove inline event handlers

    // Only remove javascript: protocol if it exists
    if (sanitized.toLowerCase().includes('javascript:')) {
        sanitized = sanitized.replace(/javascript:/gi, '');
    }

    // Remove null bytes and other dangerous control characters
    sanitized = sanitized.replace(/\x00/g, '');

    return sanitized;
}

/**
 * XSS Prevention Middleware
 * Additional layer of XSS protection with response header setting
 */
export const preventXSS = (req, res, next) => {
    // Set X-Frame-Options header
    res.setHeader('X-Frame-Options', 'DENY');

    // Set X-Content-Type-Options header
    res.setHeader('X-Content-Type-Options', 'nosniff');

    next();
};

/**
 * CSRF Token Generation and Validation
 */

/**
 * Generate CSRF token for a session
 * @param {string} sessionId - User session ID
 * @returns {string} CSRF token
 */
export function generateCsrfToken(sessionId) {
    const token = crypto.randomBytes(32).toString('hex');

    // In production, store this in Redis or session store
    // For now, we'll use a simple in-memory store
    if (!global.csrfTokens) {
        global.csrfTokens = new Map();
    }

    global.csrfTokens.set(sessionId, {
        token,
        createdAt: Date.now(),
        expiresAt: Date.now() + (60 * 60 * 1000), // 1 hour
    });

    return token;
}

/**
 * Validate CSRF token
 * @param {string} sessionId - User session ID
 * @param {string} token - CSRF token to validate
 * @returns {boolean} True if valid
 */
export function validateCsrfToken(sessionId, token) {
    if (!global.csrfTokens || !global.csrfTokens.has(sessionId)) {
        return false;
    }

    const tokenData = global.csrfTokens.get(sessionId);

    // Check if token is expired
    if (Date.now() > tokenData.expiresAt) {
        global.csrfTokens.delete(sessionId);
        return false;
    }

    return tokenData.token === token;
}

/**
 * CSRF Protection Middleware
 * Validates CSRF tokens for state-changing operations
 */
export const csrfProtection = (req, res, next) => {
    // Skip CSRF check for safe methods
    const safeMethods = ['GET', 'HEAD', 'OPTIONS'];
    if (safeMethods.includes(req.method)) {
        return next();
    }

    // Skip CSRF check for API endpoints using JWT (stateless)
    // CSRF is primarily for session-based authentication
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
        return next();
    }

    // Get CSRF token from header or body
    const csrfToken = req.headers['x-csrf-token'] || req.body._csrf;

    // Get session ID (you may need to adjust this based on your session implementation)
    const sessionId = req.session?.id || req.cookies?.sessionId;

    if (!sessionId || !csrfToken) {
        return res.status(403).json({
            success: false,
            error: 'CSRF token missing',
            message: 'CSRF token is required for this operation',
        });
    }

    // Validate token
    if (!validateCsrfToken(sessionId, csrfToken)) {
        return res.status(403).json({
            success: false,
            error: 'Invalid CSRF token',
            message: 'CSRF token is invalid or expired',
        });
    }

    next();
};

/**
 * SQL Injection Protection
 * Note: Prisma ORM already provides protection against SQL injection
 * This is an additional validation layer
 */
export const validateSqlInput = (req, res, next) => {
    // Common SQL injection patterns - more specific to avoid false positives
    const sqlInjectionPatterns = [
        /(\bOR\b\s+['"]\d+['"]\s*=\s*['"]\d+['"])/i, // OR '1'='1'
        /(\bAND\b\s+['"]\d+['"]\s*=\s*['"]\d+['"])/i, // AND '1'='1'
        /(\bUNION\b\s+SELECT\b)/i,
        /(\bDROP\b\s+TABLE\b)/i,
        /(\bINSERT\b\s+INTO\b.*?\bVALUES\b)/i,
        /(\bDELETE\b\s+FROM\b)/i,
        /(\bUPDATE\b\s+\w+\s+SET\b)/i,
        /(\bEXEC\b\s*\()/i,
        /(;\s*--)/,
        /('\s*OR\s*')/i,
        /(\bxp_\w+)/i,
    ];

    // Check all input sources
    const inputSources = [
        req.body,
        req.query,
        req.params,
    ].filter(Boolean);

    for (const source of inputSources) {
        const inputString = JSON.stringify(source);

        for (const pattern of sqlInjectionPatterns) {
            if (pattern.test(inputString)) {
                console.warn('Potential SQL injection attempt detected:', {
                    ip: req.ip,
                    path: req.path,
                    input: inputString.substring(0, 100),
                });

                return res.status(400).json({
                    success: false,
                    error: 'Invalid input',
                    message: 'Request contains potentially malicious content',
                });
            }
        }
    }

    next();
};

/**
 * Request Logging Middleware
 * Logs security-relevant information
 */
export const securityLogger = (req, res, next) => {
    const logData = {
        timestamp: new Date().toISOString(),
        method: req.method,
        path: req.path,
        ip: req.ip || req.connection.remoteAddress,
        userAgent: req.headers['user-agent'],
        userId: req.user?.id || 'anonymous',
    };

    // Log sensitive operations
    const sensitiveEndpoints = [
        '/api/auth/login',
        '/api/auth/register',
        '/api/auth/password',
        '/api/admin',
    ];

    if (sensitiveEndpoints.some(endpoint => req.path.startsWith(endpoint))) {
        console.log('Security Log:', JSON.stringify(logData));
    }

    next();
};

/**
 * Clean up expired CSRF tokens periodically
 */
export function cleanupCsrfTokens() {
    if (!global.csrfTokens) return;

    const now = Date.now();
    for (const [sessionId, tokenData] of global.csrfTokens.entries()) {
        if (now > tokenData.expiresAt) {
            global.csrfTokens.delete(sessionId);
        }
    }
}

// Run cleanup every hour
setInterval(cleanupCsrfTokens, 60 * 60 * 1000);

export default {
    securityHeaders,
    productionCorsOptions,
    globalRateLimit,
    authRateLimit,
    registerRateLimit,
    passwordResetRateLimit,
    emailVerificationRateLimit,
    vinDecodeRateLimit,
    sanitizeInput,
    preventXSS,
    generateCsrfToken,
    validateCsrfToken,
    csrfProtection,
    validateSqlInput,
    securityLogger,
    cleanupCsrfTokens,
};
