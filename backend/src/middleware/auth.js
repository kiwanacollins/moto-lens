/**
 * Authentication Middleware for MotoLens API
 *
 * Provides JWT-based authentication and authorization middleware
 * for protecting API routes.
 *
 * Features:
 * - JWT token verification
 * - User authentication validation
 * - Role-based access control (RBAC)
 * - Session validation
 * - Comprehensive error handling
 */

import JWTUtil from '../utils/jwt.js';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * Authenticate JWT token and attach user to request
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const authenticate = async (req, res, next) => {
  try {
    // Extract token from Authorization header
    const authHeader = req.headers.authorization;
    const token = JWTUtil.extractTokenFromHeader(authHeader);

    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'Authentication required',
        message: 'No token provided'
      });
    }

    // Verify token
    let decoded;
    try {
      decoded = await JWTUtil.verifyAccessToken(token);
    } catch (error) {
      return res.status(401).json({
        success: false,
        error: 'Invalid token',
        message: error.message
      });
    }

    // Fetch user from database
    const user = await prisma.user.findUnique({
      where: { id: decoded.sub },
      include: {
        profile: true
      }
    });

    // Check if user exists and is active
    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'User not found',
        message: 'User associated with this token does not exist'
      });
    }

    if (!user.isActive) {
      return res.status(403).json({
        success: false,
        error: 'Account disabled',
        message: 'Your account has been disabled. Please contact support.'
      });
    }

    // Attach user to request
    req.user = user;
    req.token = token;

    next();
  } catch (error) {
    console.error('Authentication error:', error);
    return res.status(500).json({
      success: false,
      error: 'Authentication failed',
      message: 'An error occurred during authentication'
    });
  }
};

/**
 * Require specific user role(s)
 * @param {...string} roles - Required roles (e.g., 'ADMIN', 'MECHANIC')
 * @returns {Function} Express middleware function
 */
const requireRole = (...roles) => {
  return (req, res, next) => {
    // Ensure user is authenticated
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Authentication required',
        message: 'You must be logged in to access this resource'
      });
    }

    // Check if user has required role
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        error: 'Insufficient permissions',
        message: `This resource requires one of the following roles: ${roles.join(', ')}`
      });
    }

    next();
  };
};

/**
 * Require email verification
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const requireEmailVerified = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      error: 'Authentication required',
      message: 'You must be logged in to access this resource'
    });
  }

  if (!req.user.emailVerified) {
    return res.status(403).json({
      success: false,
      error: 'Email verification required',
      message: 'Please verify your email address to access this resource'
    });
  }

  next();
};

/**
 * Require subscription tier
 * @param {...string} tiers - Required subscription tiers (e.g., 'PREMIUM', 'PROFESSIONAL')
 * @returns {Function} Express middleware function
 */
const requireSubscription = (...tiers) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Authentication required',
        message: 'You must be logged in to access this resource'
      });
    }

    if (!tiers.includes(req.user.subscriptionTier)) {
      return res.status(403).json({
        success: false,
        error: 'Subscription upgrade required',
        message: `This feature requires one of the following subscription tiers: ${tiers.join(', ')}`,
        currentTier: req.user.subscriptionTier,
        requiredTiers: tiers
      });
    }

    next();
  };
};

/**
 * Validate active session
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const validateSession = async (req, res, next) => {
  if (!req.user || !req.token) {
    return res.status(401).json({
      success: false,
      error: 'Authentication required',
      message: 'No active session found'
    });
  }

  try {
    // Check if user has any active sessions
    // Access tokens are short-lived and not stored, so we check refresh token sessions
    const activeSessions = await prisma.userSession.findMany({
      where: {
        userId: req.user.id,
        isActive: true,
        expiresAt: {
          gt: new Date()
        }
      },
      orderBy: {
        lastActivityAt: 'desc'
      },
      take: 1
    });

    if (activeSessions.length === 0) {
      return res.status(401).json({
        success: false,
        error: 'Invalid session',
        message: 'Your session has expired or been revoked. Please log in again.'
      });
    }

    const session = activeSessions[0];

    // Check session timeout
    const sessionTimeout = parseInt(process.env.SESSION_TIMEOUT_MINUTES) || 30;
    const inactiveMinutes = (Date.now() - session.lastActivityAt.getTime()) / (1000 * 60);

    if (inactiveMinutes > sessionTimeout) {
      // Mark session as inactive
      await prisma.userSession.update({
        where: { id: session.id },
        data: { isActive: false }
      });

      return res.status(401).json({
        success: false,
        error: 'Session timeout',
        message: 'Your session has expired due to inactivity. Please log in again.'
      });
    }

    // Update last activity time
    await prisma.userSession.update({
      where: { id: session.id },
      data: { lastActivityAt: new Date() }
    });

    // Attach session to request
    req.session = session;

    next();
  } catch (error) {
    console.error('Session validation error:', error);
    return res.status(500).json({
      success: false,
      error: 'Session validation failed',
      message: 'An error occurred while validating your session'
    });
  }
};

/**
 * Optional authentication - attach user if token is valid, but don't require it
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next middleware function
 */
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = JWTUtil.extractTokenFromHeader(authHeader);

    if (!token) {
      // No token provided - continue without user
      return next();
    }

    // Try to verify token
    const decoded = await JWTUtil.verifyAccessToken(token);

    // Fetch user
    const user = await prisma.user.findUnique({
      where: { id: decoded.sub },
      include: { profile: true }
    });

    if (user && user.isActive) {
      req.user = user;
      req.token = token;
    }

    next();
  } catch (error) {
    // Token invalid or expired - continue without user
    next();
  }
};

/**
 * Middleware to log security events
 * @param {string} eventType - Type of security event
 * @param {string} severity - Severity level (LOW, MEDIUM, HIGH, CRITICAL)
 * @returns {Function} Express middleware function
 */
const logSecurityEvent = (eventType, severity = 'MEDIUM') => {
  return async (req, res, next) => {
    try {
      if (req.user) {
        await prisma.securityEvent.create({
          data: {
            userId: req.user.id,
            eventType,
            severity,
            ipAddress: req.ip || req.connection.remoteAddress,
            userAgent: req.headers['user-agent'] || 'Unknown',
            details: {
              method: req.method,
              path: req.path,
              timestamp: new Date().toISOString()
            }
          }
        });
      }
    } catch (error) {
      console.error('Error logging security event:', error);
      // Don't block request if logging fails
    }
    next();
  };
};

export {
  authenticate,
  requireRole,
  requireEmailVerified,
  requireSubscription,
  validateSession,
  optionalAuth,
  logSecurityEvent
};
