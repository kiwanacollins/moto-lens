/**
 * Authentication Routes for MotoLens API
 *
 * Complete authentication system with registration, login, password management,
 * email verification, and session management.
 *
 * Routes:
 * - Registration & Login
 * - Password Recovery
 * - Email Verification
 * - Profile Management
 * - Session Management
 */

import express from 'express';
import { body, validationResult } from 'express-validator';
import rateLimit from 'express-rate-limit';
import { PrismaClient } from '@prisma/client';
import JWTUtil from '../utils/jwt.js';
import PasswordUtil from '../utils/password.js';
import EmailService from '../services/emailService.js';
import { authenticate, optionalAuth } from '../middleware/auth.js';

const router = express.Router();
const prisma = new PrismaClient();

/**
 * Rate Limiters
 */

// Strict rate limit for login attempts (10 per 15 minutes)
const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10,
  message: {
    success: false,
    error: 'Too many login attempts',
    message: 'Please try again after 15 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false
});

// Moderate rate limit for registration (5 per hour)
const registerLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5,
  message: {
    success: false,
    error: 'Too many registration attempts',
    message: 'Please try again after 1 hour'
  }
});

// Moderate rate limit for password reset (3 per hour)
const passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3,
  message: {
    success: false,
    error: 'Too many password reset attempts',
    message: 'Please try again after 1 hour'
  }
});

// Lenient rate limit for email verification (10 per hour)
const emailVerificationLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10,
  message: {
    success: false,
    error: 'Too many verification attempts',
    message: 'Please try again after 1 hour'
  }
});

/**
 * Validation Middleware
 */

const validateRegistration = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Valid email is required'),
  body('password')
    .isLength({ min: 8 })
    .withMessage('Password must be at least 8 characters'),
  body('firstName')
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('First name is required (1-50 characters)'),
  body('lastName')
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('Last name is required (1-50 characters)'),
  body('role')
    .optional()
    .isIn(['mechanic', 'shop_owner', 'admin'])
    .withMessage('Invalid role')
];

const validateLogin = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Valid email is required'),
  body('password')
    .notEmpty()
    .withMessage('Password is required')
];

const validatePasswordChange = [
  body('currentPassword')
    .notEmpty()
    .withMessage('Current password is required'),
  body('newPassword')
    .isLength({ min: 8 })
    .withMessage('New password must be at least 8 characters')
];

const validatePasswordReset = [
  body('token')
    .notEmpty()
    .withMessage('Reset token is required'),
  body('newPassword')
    .isLength({ min: 8 })
    .withMessage('New password must be at least 8 characters')
];

const validateEmailToken = [
  body('token')
    .notEmpty()
    .withMessage('Verification token is required')
];

const validateProfileUpdate = [
  body('firstName')
    .optional()
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('First name must be 1-50 characters'),
  body('lastName')
    .optional()
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('Last name must be 1-50 characters'),
  body('phone')
    .optional()
    .matches(/^\+?[1-9]\d{1,14}$/)
    .withMessage('Invalid phone number format')
];

/**
 * Helper Functions
 */

// Extract validation errors
function getValidationErrors(req) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return errors.array().map(err => err.msg);
  }
  return null;
}

// Log security event
async function logSecurityEvent(userId, eventType, severity, description) {
  // Map valid severities (schema only allows INFO, WARNING, ERROR, CRITICAL)
  const severityMap = { LOW: 'INFO', MEDIUM: 'WARNING' };
  const safeSeverity = severityMap[severity] || severity;

  // Convert object descriptions to a string + metadata
  let descriptionStr;
  let metadata = {};
  if (typeof description === 'object' && description !== null) {
    metadata = description;
    descriptionStr = JSON.stringify(description);
  } else {
    descriptionStr = description || 'Security event logged';
  }

  try {
    await prisma.securityEvent.create({
      data: {
        userId,
        eventType,
        severity: safeSeverity,
        description: descriptionStr,
        metadata
      }
    });
  } catch (error) {
    console.error('Failed to log security event:', error);
    // Don't throw - logging failure shouldn't block the request
  }
}

// Get device info from request
function getDeviceInfo(req) {
  return {
    userAgent: req.headers['user-agent'] || 'Unknown',
    ipAddress: req.ip || req.connection.remoteAddress || 'Unknown',
    platform: req.headers['sec-ch-ua-platform'] || 'Unknown'
  };
}

/**
 * ========================================
 * REGISTRATION & LOGIN ROUTES
 * ========================================
 */

/**
 * POST /api/auth/register
 * Register a new user account
 */
router.post('/register', registerLimiter, validateRegistration, async (req, res) => {
  try {
    // Check for validation errors
    const validationErrors = getValidationErrors(req);
    if (validationErrors) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: validationErrors
      });
    }

    const { email, password, firstName, lastName, role = 'mechanic' } = req.body;

    // Convert role string to Prisma enum value
    const roleMapping = {
      'mechanic': 'MECHANIC',
      'shop_owner': 'SHOP_OWNER',
      'admin': 'ADMIN',
      'support': 'SUPPORT'
    };
    const prismaRole = roleMapping[role.toLowerCase()] || 'MECHANIC';

    // Check if user already exists
    const existingUser = await prisma.user.findUnique({
      where: { email }
    });

    if (existingUser) {
      return res.status(409).json({
        success: false,
        error: 'User already exists',
        message: 'An account with this email already exists'
      });
    }

    // Validate password strength
    const passwordValidation = PasswordUtil.validateStrength(password);
    if (!passwordValidation.isValid) {
      return res.status(400).json({
        success: false,
        error: 'Password validation failed',
        details: passwordValidation.feedback,
        strength: passwordValidation.strength,
        score: passwordValidation.score
      });
    }

    // Hash password
    const passwordHash = await PasswordUtil.hash(password);

    // Create user
    const user = await prisma.user.create({
      data: {
        email,
        passwordHash,
        firstName,
        lastName,
        role: prismaRole,
        emailVerified: false,
        failedLoginAttempts: 0
      }
    });

    // Generate email verification token
    const verificationToken = PasswordUtil.generateSecureToken();
    const tokenHash = PasswordUtil.hashToken(verificationToken);

    await prisma.emailVerificationToken.create({
      data: {
        userId: user.id,
        email,
        token: verificationToken,
        tokenHash,
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 hours
      }
    });

    // Send verification email (non-blocking)
    EmailService.sendVerificationEmail(user, verificationToken)
      .catch(err => console.error('Failed to send verification email:', err));

    // Log registration event
    await logSecurityEvent(user.id, 'LOGIN_SUCCESS', 'INFO', `User registered: ${user.email}, role: ${user.role}`);

    // Auto-login: generate tokens and create session so user is immediately authenticated
    const tokens = JWTUtil.generateTokenPair(user);
    const deviceInfo = getDeviceInfo(req);

    const session = await prisma.userSession.create({
      data: {
        userId: user.id,
        refreshToken: tokens.refreshToken,
        refreshTokenHash: PasswordUtil.hashToken(tokens.refreshToken),
        userAgent: deviceInfo.userAgent,
        ipAddress: deviceInfo.ipAddress,
        deviceType: 'mobile',
        isActive: true,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
        lastActivityAt: new Date()
      }
    });

    res.status(201).json({
      success: true,
      message: 'Registration successful. Please check your email to verify your account.',
      tokens: {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken
      },
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        emailVerified: user.emailVerified,
        subscriptionTier: user.subscriptionTier
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      error: 'Registration failed',
      message: 'An error occurred during registration'
    });
  }
});

/**
 * POST /api/auth/login
 * Authenticate user and return tokens
 */
router.post('/login', loginLimiter, validateLogin, async (req, res) => {
  try {
    // Check for validation errors
    const validationErrors = getValidationErrors(req);
    if (validationErrors) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: validationErrors
      });
    }

    const { email, password } = req.body;

    // Find user
    const user = await prisma.user.findUnique({
      where: { email }
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Invalid credentials',
        message: 'Email or password is incorrect'
      });
    }

    // Check account lockout
    const lockoutStatus = await PasswordUtil.checkAccountLockout(user.id);
    if (lockoutStatus.isLocked) {
      return res.status(423).json({
        success: false,
        error: 'Account locked',
        message: `Too many failed login attempts. Try again in ${lockoutStatus.minutesRemaining} minutes.`,
        lockedUntil: lockoutStatus.lockedUntil
      });
    }

    // Verify password
    const isValid = await PasswordUtil.verify(password, user.passwordHash);

    if (!isValid) {
      // Record failed attempt
      const result = await PasswordUtil.recordFailedLogin(user.id);

      return res.status(401).json({
        success: false,
        error: 'Invalid credentials',
        message: 'Email or password is incorrect',
        remainingAttempts: result.remainingAttempts,
        ...(result.isLocked && {
          accountLocked: true,
          lockedUntil: result.lockedUntil
        })
      });
    }

    // Reset failed attempts on successful login
    await PasswordUtil.resetFailedLoginAttempts(user.id);

    // Invalidate any existing active sessions for this user
    // This prevents duplicate refresh token issues and enhances security
    await prisma.userSession.updateMany({
      where: {
        userId: user.id,
        isActive: true
      },
      data: {
        isActive: false,
        lastActivityAt: new Date()
      }
    });

    // Generate tokens (includes unique jti to prevent collisions)
    const tokens = JWTUtil.generateTokenPair(user);
    const deviceInfo = getDeviceInfo(req);

    // Delete old inactive sessions for this user to prevent stale data buildup
    await prisma.userSession.deleteMany({
      where: {
        userId: user.id,
        isActive: false
      }
    });

    // Create session
    const session = await prisma.userSession.create({
      data: {
        userId: user.id,
        refreshToken: tokens.refreshToken,
        refreshTokenHash: PasswordUtil.hashToken(tokens.refreshToken),
        userAgent: deviceInfo.userAgent,
        ipAddress: deviceInfo.ipAddress,
        deviceType: 'mobile', // Can be enhanced to detect actual device type
        isActive: true,
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
        lastActivityAt: new Date()
      }
    });

    // Log successful login
    await logSecurityEvent(
      user.id,
      'LOGIN_SUCCESS',
      'INFO',
      `Login successful - Session: ${session.id}`
    );

    res.json({
      success: true,
      message: 'Login successful',
      tokens: {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken
      },
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        emailVerified: user.emailVerified,
        subscriptionTier: user.subscriptionTier
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      error: 'Login failed',
      message: 'An error occurred during login'
    });
  }
});

/**
 * POST /api/auth/logout
 * Logout current session
 */
router.post('/logout', authenticate, async (req, res) => {
  try {
    const refreshToken = req.body.refreshToken;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        error: 'Refresh token required',
        message: 'Please provide refresh token to logout'
      });
    }

    // Blacklist the refresh token
    await JWTUtil.blacklistToken(refreshToken, 'logout');

    // Log logout event
    await logSecurityEvent(req.user.id, 'LOGOUT', 'INFO', {
      deviceInfo: getDeviceInfo(req)
    });

    res.json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({
      success: false,
      error: 'Logout failed',
      message: 'An error occurred during logout'
    });
  }
});

/**
 * POST /api/auth/logout-all
 * Logout all sessions for the user
 */
router.post('/logout-all', authenticate, async (req, res) => {
  try {
    // Deactivate all user sessions
    await prisma.userSession.updateMany({
      where: {
        userId: req.user.id,
        isActive: true
      },
      data: {
        isActive: false,
        lastActivityAt: new Date()
      }
    });

    // Log logout all event
    await logSecurityEvent(req.user.id, 'LOGOUT_ALL_DEVICES', 'INFO', {
      deviceInfo: getDeviceInfo(req)
    });

    res.json({
      success: true,
      message: 'Logged out of all devices successfully'
    });
  } catch (error) {
    console.error('Logout all error:', error);
    res.status(500).json({
      success: false,
      error: 'Logout failed',
      message: 'An error occurred during logout'
    });
  }
});

/**
 * POST /api/auth/refresh-token
 * Refresh access token using refresh token
 */
router.post('/refresh-token', async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        error: 'Refresh token required',
        message: 'Please provide refresh token'
      });
    }

    // Verify refresh token
    const decoded = await JWTUtil.verifyRefreshToken(refreshToken);

    // Get user
    const user = await prisma.user.findUnique({
      where: { id: decoded.sub }
    });

    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Invalid token',
        message: 'User not found'
      });
    }

    // Rotate tokens (generate new pair)
    const newTokens = await JWTUtil.rotateTokens(refreshToken, user);

    res.json({
      success: true,
      message: 'Token refreshed successfully',
      tokens: {
        accessToken: newTokens.accessToken,
        refreshToken: newTokens.refreshToken
      }
    });
  } catch (error) {
    console.error('Token refresh error:', error);
    res.status(401).json({
      success: false,
      error: 'Token refresh failed',
      message: error.message || 'Invalid or expired refresh token'
    });
  }
});

/**
 * GET /api/auth/me
 * Get current authenticated user
 */
router.get('/me', authenticate, async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        role: true,
        emailVerified: true,
        subscriptionTier: true,
        subscriptionExpiresAt: true,
        createdAt: true,
        updatedAt: true
      }
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found'
      });
    }

    res.json({
      success: true,
      user
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get user',
      message: 'An error occurred while fetching user data'
    });
  }
});

/**
 * ========================================
 * PROFILE MANAGEMENT ROUTES
 * ========================================
 */

/**
 * PUT /api/auth/profile
 * Update user profile
 */
router.put('/profile', authenticate, validateProfileUpdate, async (req, res) => {
  try {
    // Check for validation errors
    const validationErrors = getValidationErrors(req);
    if (validationErrors) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: validationErrors
      });
    }

    const { firstName, lastName, phone } = req.body;

    // Build update data (only include provided fields)
    const updateData = {};
    if (firstName !== undefined) updateData.firstName = firstName;
    if (lastName !== undefined) updateData.lastName = lastName;
    if (phone !== undefined) updateData.phone = phone;

    // Update user
    const updatedUser = await prisma.user.update({
      where: { id: req.user.id },
      data: updateData,
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        phone: true,
        role: true,
        emailVerified: true,
        updatedAt: true
      }
    });

    // Log profile update
    await logSecurityEvent(req.user.id, 'LOGIN_SUCCESS', 'INFO', `Profile updated: ${Object.keys(updateData).join(', ')}`);

    res.json({
      success: true,
      message: 'Profile updated successfully',
      user: updatedUser
    });
  } catch (error) {
    console.error('Profile update error:', error);
    res.status(500).json({
      success: false,
      error: 'Profile update failed',
      message: 'An error occurred while updating profile'
    });
  }
});

/**
 * PUT /api/auth/change-password
 * Change user password (requires current password)
 */
router.put('/change-password', authenticate, validatePasswordChange, async (req, res) => {
  try {
    // Check for validation errors
    const validationErrors = getValidationErrors(req);
    if (validationErrors) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: validationErrors
      });
    }

    const { currentPassword, newPassword } = req.body;

    // Get user with password hash
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: {
        id: true,
        email: true,
        firstName: true,
        passwordHash: true
      }
    });

    // Verify current password
    const isValid = await PasswordUtil.verify(currentPassword, user.passwordHash);

    if (!isValid) {
      return res.status(401).json({
        success: false,
        error: 'Invalid password',
        message: 'Current password is incorrect'
      });
    }

    // Update password with history tracking
    await PasswordUtil.updatePasswordWithHistory(user.id, newPassword);

    // Send password change notification (non-blocking)
    EmailService.sendPasswordChangeNotification(user)
      .catch(err => console.error('Failed to send notification:', err));

    // Log password change
    await logSecurityEvent(user.id, 'PASSWORD_CHANGED', 'MEDIUM', {
      deviceInfo: getDeviceInfo(req)
    });

    res.json({
      success: true,
      message: 'Password updated successfully'
    });
  } catch (error) {
    console.error('Password change error:', error);

    // Handle specific password validation errors
    if (error.message && error.message.includes('Password has been used recently')) {
      return res.status(400).json({
        success: false,
        error: 'Password reuse',
        message: error.message
      });
    }

    if (error.message && error.message.includes('Password validation failed')) {
      return res.status(400).json({
        success: false,
        error: 'Password validation failed',
        message: error.message
      });
    }

    res.status(500).json({
      success: false,
      error: 'Password change failed',
      message: 'An error occurred while changing password'
    });
  }
});

/**
 * ========================================
 * PASSWORD RECOVERY ROUTES
 * ========================================
 */

/**
 * POST /api/auth/forgot-password
 * Request password reset email
 */
router.post('/forgot-password', passwordResetLimiter, async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        error: 'Email required',
        message: 'Please provide your email address'
      });
    }

    // Find user (don't reveal if email exists for security)
    const user = await prisma.user.findUnique({
      where: { email }
    });

    // Always return success to prevent email enumeration
    const successResponse = {
      success: true,
      message: 'If that email exists, a password reset link has been sent'
    };

    if (!user) {
      // Log attempted reset for non-existent email
      await logSecurityEvent(null, 'PASSWORD_RESET_REQUEST', 'INFO', `Password reset attempted for non-existent email: ${email}`);
      return res.json(successResponse);
    }

    // Delete any existing reset tokens for this user
    await prisma.passwordResetToken.deleteMany({
      where: { userId: user.id }
    });

    // Generate reset token
    const resetToken = PasswordUtil.generateSecureToken();
    const tokenHash = PasswordUtil.hashToken(resetToken);

    await prisma.passwordResetToken.create({
      data: {
        userId: user.id,
        token: resetToken,
        tokenHash,
        expiresAt: new Date(Date.now() + 60 * 60 * 1000) // 1 hour
      }
    });

    // Send reset email (non-blocking)
    EmailService.sendPasswordResetEmail(user, resetToken)
      .catch(err => console.error('Failed to send password reset email:', err));

    // Log password reset request
    await logSecurityEvent(user.id, 'PASSWORD_RESET_REQUEST', 'INFO', `Password reset requested for: ${user.email}`);

    res.json(successResponse);
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({
      success: false,
      error: 'Password reset failed',
      message: 'An error occurred while processing password reset'
    });
  }
});

/**
 * POST /api/auth/reset-password
 * Reset password using token
 */
router.post('/reset-password', passwordResetLimiter, validatePasswordReset, async (req, res) => {
  try {
    // Check for validation errors
    const validationErrors = getValidationErrors(req);
    if (validationErrors) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: validationErrors
      });
    }

    const { token, newPassword } = req.body;

    // Hash the token to find it in database
    const tokenHash = PasswordUtil.hashToken(token);

    // Find valid reset token
    const resetToken = await prisma.passwordResetToken.findFirst({
      where: {
        tokenHash,
        expiresAt: {
          gt: new Date() // Token not expired
        }
      },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            firstName: true
          }
        }
      }
    });

    if (!resetToken) {
      return res.status(400).json({
        success: false,
        error: 'Invalid or expired token',
        message: 'Password reset token is invalid or has expired'
      });
    }

    // Update password with history tracking
    await PasswordUtil.updatePasswordWithHistory(resetToken.userId, newPassword);

    // Delete used reset token
    await prisma.passwordResetToken.delete({
      where: { id: resetToken.id }
    });

    // Invalidate all sessions for security
    await prisma.userSession.updateMany({
      where: {
        userId: resetToken.userId,
        isActive: true
      },
      data: {
        isActive: false,
        lastActivityAt: new Date()
      }
    });

    // Send password change notification (non-blocking)
    EmailService.sendPasswordChangeNotification(resetToken.user)
      .catch(err => console.error('Failed to send notification:', err));

    // Log password reset
    await logSecurityEvent(resetToken.userId, 'PASSWORD_RESET_SUCCESS', 'INFO', `Password reset completed for: ${resetToken.user.email}`);

    res.json({
      success: true,
      message: 'Password reset successful. Please log in with your new password.'
    });
  } catch (error) {
    console.error('Password reset error:', error);

    // Handle specific password validation errors
    if (error.message && error.message.includes('Password has been used recently')) {
      return res.status(400).json({
        success: false,
        error: 'Password reuse',
        message: error.message
      });
    }

    if (error.message && error.message.includes('Password validation failed')) {
      return res.status(400).json({
        success: false,
        error: 'Password validation failed',
        message: error.message
      });
    }

    res.status(500).json({
      success: false,
      error: 'Password reset failed',
      message: 'An error occurred while resetting password'
    });
  }
});

/**
 * ========================================
 * EMAIL VERIFICATION ROUTES
 * ========================================
 */

/**
 * POST /api/auth/verify-email
 * Verify email address using token
 */
router.post('/verify-email', emailVerificationLimiter, validateEmailToken, async (req, res) => {
  try {
    // Check for validation errors
    const validationErrors = getValidationErrors(req);
    if (validationErrors) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: validationErrors
      });
    }

    const { token } = req.body;

    // Hash the token to find it in database
    const tokenHash = PasswordUtil.hashToken(token);

    // Find valid verification token
    const verificationToken = await prisma.emailVerificationToken.findFirst({
      where: {
        tokenHash,
        expiresAt: {
          gt: new Date() // Token not expired
        }
      },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            emailVerified: true
          }
        }
      }
    });

    if (!verificationToken) {
      return res.status(400).json({
        success: false,
        error: 'Invalid or expired token',
        message: 'Email verification token is invalid or has expired'
      });
    }

    // Check if already verified
    if (verificationToken.user.emailVerified) {
      return res.json({
        success: true,
        message: 'Email already verified'
      });
    }

    // Mark email as verified
    await prisma.user.update({
      where: { id: verificationToken.userId },
      data: { emailVerified: true }
    });

    // Delete used verification token
    await prisma.emailVerificationToken.delete({
      where: { id: verificationToken.id }
    });

    // Log email verification
    await logSecurityEvent(verificationToken.userId, 'EMAIL_VERIFIED', 'INFO', `Email verified: ${verificationToken.user.email}`);

    res.json({
      success: true,
      message: 'Email verified successfully'
    });
  } catch (error) {
    console.error('Email verification error:', error);
    res.status(500).json({
      success: false,
      error: 'Email verification failed',
      message: 'An error occurred while verifying email'
    });
  }
});

/**
 * POST /api/auth/resend-verification
 * Resend email verification
 */
router.post('/resend-verification', emailVerificationLimiter, optionalAuth, async (req, res) => {
  try {
    let user;

    // Get user from auth or email
    if (req.user) {
      user = req.user;
    } else if (req.body.email) {
      user = await prisma.user.findUnique({
        where: { email: req.body.email }
      });
    } else {
      return res.status(400).json({
        success: false,
        error: 'Email required',
        message: 'Please provide email or authenticate'
      });
    }

    if (!user) {
      // Don't reveal if email exists
      return res.json({
        success: true,
        message: 'If that email exists and is unverified, a verification link has been sent'
      });
    }

    // Check if already verified
    if (user.emailVerified) {
      return res.json({
        success: true,
        message: 'Email already verified'
      });
    }

    // Delete existing verification tokens
    await prisma.emailVerificationToken.deleteMany({
      where: { userId: user.id }
    });

    // Generate new verification token
    const verificationToken = PasswordUtil.generateSecureToken();
    const tokenHash = PasswordUtil.hashToken(verificationToken);

    await prisma.emailVerificationToken.create({
      data: {
        userId: user.id,
        email: user.email,
        token: verificationToken,
        tokenHash,
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 hours
      }
    });

    // Send verification email (non-blocking)
    EmailService.sendVerificationEmail(user, verificationToken)
      .catch(err => console.error('Failed to send verification email:', err));

    // Log verification resend
    await logSecurityEvent(user.id, 'EMAIL_VERIFIED', 'INFO', `Verification email resent to: ${user.email}`);

    res.json({
      success: true,
      message: 'Verification email sent. Please check your inbox.'
    });
  } catch (error) {
    console.error('Resend verification error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to resend verification',
      message: 'An error occurred while sending verification email'
    });
  }
});

/**
 * ========================================
 * SESSION MANAGEMENT ROUTES
 * ========================================
 */

/**
 * GET /api/auth/sessions
 * Get all active sessions for current user
 */
router.get('/sessions', authenticate, async (req, res) => {
  try {
    const sessions = await prisma.userSession.findMany({
      where: {
        userId: req.user.id,
        isActive: true,
        expiresAt: {
          gt: new Date()
        }
      },
      select: {
        id: true,
        deviceFingerprint: true,
        ipAddress: true,
        createdAt: true,
        lastActivityAt: true,
        expiresAt: true
      },
      orderBy: {
        lastActivityAt: 'desc'
      }
    });

    res.json({
      success: true,
      sessions
    });
  } catch (error) {
    console.error('Get sessions error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get sessions',
      message: 'An error occurred while fetching sessions'
    });
  }
});

/**
 * DELETE /api/auth/sessions/:sessionId
 * Delete a specific session
 */
router.delete('/sessions/:sessionId', authenticate, async (req, res) => {
  try {
    const { sessionId } = req.params;

    // Verify session belongs to user
    const session = await prisma.userSession.findFirst({
      where: {
        id: sessionId,
        userId: req.user.id
      }
    });

    if (!session) {
      return res.status(404).json({
        success: false,
        error: 'Session not found',
        message: 'Session does not exist or does not belong to you'
      });
    }

    // Deactivate session
    await prisma.userSession.update({
      where: { id: sessionId },
      data: {
        isActive: false,
        lastActivityAt: new Date()
      }
    });

    // Log session deletion
    await logSecurityEvent(req.user.id, 'LOGOUT', 'INFO', `Session deleted: ${sessionId}`);

    res.json({
      success: true,
      message: 'Session deleted successfully'
    });
  } catch (error) {
    console.error('Delete session error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete session',
      message: 'An error occurred while deleting session'
    });
  }
});

/**
 * DELETE /api/auth/sessions
 * Delete all sessions except current one
 */
router.delete('/sessions', authenticate, async (req, res) => {
  try {
    const currentRefreshToken = req.body.currentRefreshToken;

    if (!currentRefreshToken) {
      return res.status(400).json({
        success: false,
        error: 'Current refresh token required',
        message: 'Please provide your current refresh token to keep this session active'
      });
    }

    // Deactivate all sessions except current one
    await prisma.userSession.updateMany({
      where: {
        userId: req.user.id,
        isActive: true,
        refreshToken: {
          not: currentRefreshToken
        }
      },
      data: {
        isActive: false,
        lastActivityAt: new Date()
      }
    });

    // Log sessions deletion
    await logSecurityEvent(req.user.id, 'LOGOUT_ALL_DEVICES', 'WARNING', `All other sessions deleted`);

    res.json({
      success: true,
      message: 'All other sessions deleted successfully'
    });
  } catch (error) {
    console.error('Delete all sessions error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete sessions',
      message: 'An error occurred while deleting sessions'
    });
  }
});

export default router;
