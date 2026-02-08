/**
 * JWT Utilities for German Car Medic Authentication
 *
 * Provides secure token generation, verification, and management
 * for the authentication system.
 *
 * Features:
 * - Access token generation (15 minutes)
 * - Refresh token generation (7 days)
 * - Token verification with comprehensive error handling
 * - Token blacklisting for logout/security
 * - Token rotation support
 */

import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

class JWTUtil {
  /**
   * Generate an access token for authenticated user
   * @param {Object} user - User object from database
   * @returns {string} Signed JWT access token
   */
  static generateAccessToken(user) {
    if (!user || !user.id) {
      throw new Error('Invalid user object for token generation');
    }

    return jwt.sign(
      {
        sub: user.id,
        email: user.email,
        role: user.role,
        type: 'access'
      },
      process.env.JWT_SECRET,
      {
        expiresIn: process.env.JWT_ACCESS_TOKEN_EXPIRY || '15m',
        issuer: 'germancarmedic-api',
        audience: 'germancarmedic-app'
      }
    );
  }

  /**
   * Generate a refresh token for token rotation
   * @param {Object} user - User object from database
   * @returns {string} Signed JWT refresh token
   */
  static generateRefreshToken(user) {
    if (!user || !user.id) {
      throw new Error('Invalid user object for token generation');
    }

    return jwt.sign(
      {
        sub: user.id,
        type: 'refresh',
        jti: crypto.randomUUID() // Unique ID to prevent duplicate tokens
      },
      process.env.JWT_REFRESH_SECRET,
      {
        expiresIn: process.env.JWT_REFRESH_TOKEN_EXPIRY || '7d',
        issuer: 'germancarmedic-api',
        audience: 'germancarmedic-app'
      }
    );
  }

  /**
   * Verify and decode an access token
   * @param {string} token - JWT access token to verify
   * @returns {Object} Decoded token payload
   * @throws {Error} If token is invalid, expired, or blacklisted
   */
  static async verifyAccessToken(token) {
    if (!token) {
      throw new Error('Token is required');
    }

    try {
      // Check if token is blacklisted
      const isBlacklisted = await this.isTokenBlacklisted(token);
      if (isBlacklisted) {
        throw new Error('Token has been revoked');
      }

      // Verify token signature and expiration
      const decoded = jwt.verify(token, process.env.JWT_SECRET, {
        issuer: 'germancarmedic-api',
        audience: 'germancarmedic-app'
      });

      // Verify token type
      if (decoded.type !== 'access') {
        throw new Error('Invalid token type');
      }

      return decoded;
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw new Error('Access token has expired');
      }
      if (error.name === 'JsonWebTokenError') {
        throw new Error('Invalid access token');
      }
      throw error;
    }
  }

  /**
   * Verify and decode a refresh token
   * @param {string} token - JWT refresh token to verify
   * @returns {Object} Decoded token payload
   * @throws {Error} If token is invalid, expired, or blacklisted
   */
  static async verifyRefreshToken(token) {
    if (!token) {
      throw new Error('Token is required');
    }

    try {
      // Check if token is blacklisted
      const isBlacklisted = await this.isTokenBlacklisted(token);
      if (isBlacklisted) {
        throw new Error('Token has been revoked');
      }

      // Verify token signature and expiration
      const decoded = jwt.verify(token, process.env.JWT_REFRESH_SECRET, {
        issuer: 'germancarmedic-api',
        audience: 'germancarmedic-app'
      });

      // Verify token type
      if (decoded.type !== 'refresh') {
        throw new Error('Invalid token type');
      }

      return decoded;
    } catch (error) {
      if (error.name === 'TokenExpiredError') {
        throw new Error('Refresh token has expired');
      }
      if (error.name === 'JsonWebTokenError') {
        throw new Error('Invalid refresh token');
      }
      throw error;
    }
  }

  /**
   * Blacklist a token (for logout or security revocation)
   * @param {string} token - JWT token to blacklist (refresh token)
   * @param {string} reason - Reason for blacklisting (e.g., 'logout', 'security')
   * @returns {Promise<Object>} Created blacklist record
   */
  static async blacklistToken(token, reason = 'logout') {
    if (!token) {
      throw new Error('Token is required for blacklisting');
    }

    try {
      // Decode token to get expiration (without verification)
      const decoded = jwt.decode(token);
      if (!decoded || !decoded.exp) {
        throw new Error('Invalid token format');
      }

      // Calculate expiration date
      const expiresAt = new Date(decoded.exp * 1000);

      // Mark session as inactive based on refresh token
      // Access tokens are short-lived (15m) so we track refresh tokens
      await prisma.userSession.updateMany({
        where: {
          userId: decoded.sub,
          refreshToken: token
        },
        data: {
          isActive: false,
          lastActivityAt: new Date()
        }
      });

      return {
        success: true,
        message: 'Token blacklisted successfully',
        reason,
        expiresAt
      };
    } catch (error) {
      console.error('Error blacklisting token:', error);
      throw new Error('Failed to blacklist token');
    }
  }

  /**
   * Check if a token is blacklisted
   * @param {string} token - JWT token to check (refresh token)
   * @returns {Promise<boolean>} True if blacklisted, false otherwise
   */
  static async isTokenBlacklisted(token) {
    if (!token) {
      return false;
    }

    try {
      // Decode token to get user ID and type (without verification)
      const decoded = jwt.decode(token);
      if (!decoded || !decoded.sub || !decoded.type) {
        return false;
      }

      // Only check refresh tokens in database
      // Access tokens are short-lived and not stored
      if (decoded.type === 'refresh') {
        const session = await prisma.userSession.findFirst({
          where: {
            userId: decoded.sub,
            refreshToken: token,
            isActive: false
          }
        });
        return !!session;
      }

      // Access tokens: check if user has any active sessions
      // If no active sessions, consider all access tokens invalid
      const activeSessions = await prisma.userSession.count({
        where: {
          userId: decoded.sub,
          isActive: true,
          expiresAt: {
            gt: new Date()
          }
        }
      });

      return activeSessions === 0;
    } catch (error) {
      console.error('Error checking token blacklist:', error);
      return false;
    }
  }

  /**
   * Generate both access and refresh tokens
   * @param {Object} user - User object from database
   * @returns {Object} Object containing both tokens
   */
  static generateTokenPair(user) {
    return {
      accessToken: this.generateAccessToken(user),
      refreshToken: this.generateRefreshToken(user),
      expiresIn: 900 // 15 minutes in seconds
    };
  }

  /**
   * Rotate tokens - generate new pair and blacklist old refresh token
   * @param {string} oldRefreshToken - Current refresh token
   * @param {Object} user - User object from database
   * @returns {Object} New token pair
   */
  static async rotateTokens(oldRefreshToken, user) {
    // Verify old refresh token
    await this.verifyRefreshToken(oldRefreshToken);

    // Blacklist old refresh token
    await this.blacklistToken(oldRefreshToken, 'token_rotation');

    // Generate new token pair
    return this.generateTokenPair(user);
  }

  /**
   * Extract token from Authorization header
   * @param {string} authHeader - Authorization header value
   * @returns {string|null} Extracted token or null
   */
  static extractTokenFromHeader(authHeader) {
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }
    return authHeader.substring(7);
  }

  /**
   * Decode token without verification (for debugging/logging)
   * @param {string} token - JWT token
   * @returns {Object|null} Decoded payload or null
   */
  static decodeToken(token) {
    try {
      return jwt.decode(token);
    } catch (error) {
      return null;
    }
  }

  /**
   * Get token expiration time
   * @param {string} token - JWT token
   * @returns {Date|null} Expiration date or null
   */
  static getTokenExpiration(token) {
    const decoded = this.decodeToken(token);
    if (!decoded || !decoded.exp) {
      return null;
    }
    return new Date(decoded.exp * 1000);
  }

  /**
   * Check if token is expired (without verification)
   * @param {string} token - JWT token
   * @returns {boolean} True if expired
   */
  static isTokenExpired(token) {
    const expiration = this.getTokenExpiration(token);
    if (!expiration) {
      return true;
    }
    return expiration < new Date();
  }
}

export default JWTUtil;
