/**
 * Password Security Utilities for German Car Medic Authentication
 *
 * Provides secure password hashing, verification, and validation
 * for the authentication system.
 *
 * Features:
 * - bcrypt password hashing (12 rounds)
 * - Password strength validation
 * - Secure token generation for password reset
 * - Password history checking (prevent reuse)
 * - Account lockout tracking
 */

import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

class PasswordUtil {
  /**
   * Hash a password using bcrypt
   * @param {string} password - Plain text password
   * @returns {Promise<string>} Hashed password
   */
  static async hash(password) {
    if (!password || typeof password !== 'string') {
      throw new Error('Password must be a non-empty string');
    }

    if (password.length < 8) {
      throw new Error('Password must be at least 8 characters long');
    }

    // Use 12 salt rounds for strong security
    const saltRounds = 12;
    return await bcrypt.hash(password, saltRounds);
  }

  /**
   * Verify a password against a hash
   * @param {string} password - Plain text password
   * @param {string} hash - Hashed password
   * @returns {Promise<boolean>} True if password matches
   */
  static async verify(password, hash) {
    if (!password || !hash) {
      return false;
    }

    try {
      return await bcrypt.compare(password, hash);
    } catch (error) {
      console.error('Password verification error:', error);
      return false;
    }
  }

  /**
   * Validate password strength
   * @param {string} password - Password to validate
   * @returns {Object} Validation result with requirements and score
   */
  static validateStrength(password) {
    if (!password || typeof password !== 'string') {
      return {
        isValid: false,
        score: 0,
        requirements: {},
        strength: 'invalid',
        feedback: ['Password is required']
      };
    }

    // Get password requirements from environment or use defaults
    const minLength = parseInt(process.env.MIN_PASSWORD_LENGTH) || 8;
    const requireUppercase = process.env.REQUIRE_UPPERCASE !== 'false';
    const requireLowercase = process.env.REQUIRE_LOWERCASE !== 'false';
    const requireNumbers = process.env.REQUIRE_NUMBERS !== 'false';
    const requireSpecialChars = process.env.REQUIRE_SPECIAL_CHARS === 'true';

    // Check requirements
    const requirements = {
      minLength: password.length >= minLength,
      hasUppercase: /[A-Z]/.test(password),
      hasLowercase: /[a-z]/.test(password),
      hasNumbers: /\d/.test(password),
      hasSpecialChar: /[!@#$%^&*(),.?":{}|<>]/.test(password),
      noCommonPasswords: !this.isCommonPassword(password)
    };

    // Calculate score (0-6)
    let score = 0;
    if (requirements.minLength) score++;
    if (requirements.hasUppercase) score++;
    if (requirements.hasLowercase) score++;
    if (requirements.hasNumbers) score++;
    if (requirements.hasSpecialChar) score++;
    if (requirements.noCommonPasswords) score++;

    // Bonus points for extra length
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;

    // Determine strength level
    let strength = 'weak';
    if (score >= 6) strength = 'strong';
    else if (score >= 4) strength = 'medium';

    // Build feedback array
    const feedback = [];
    if (!requirements.minLength) feedback.push(`Must be at least ${minLength} characters`);
    if (requireUppercase && !requirements.hasUppercase) feedback.push('Must contain uppercase letter');
    if (requireLowercase && !requirements.hasLowercase) feedback.push('Must contain lowercase letter');
    if (requireNumbers && !requirements.hasNumbers) feedback.push('Must contain a number');
    if (requireSpecialChars && !requirements.hasSpecialChar) feedback.push('Must contain special character (!@#$%^&*)');
    if (!requirements.noCommonPasswords) feedback.push('Password is too common');

    // Determine if valid based on required criteria
    const isValid =
      requirements.minLength &&
      (!requireUppercase || requirements.hasUppercase) &&
      (!requireLowercase || requirements.hasLowercase) &&
      (!requireNumbers || requirements.hasNumbers) &&
      (!requireSpecialChars || requirements.hasSpecialChar) &&
      requirements.noCommonPasswords;

    return {
      isValid,
      score: Math.min(score, 8),
      requirements,
      strength,
      feedback: feedback.length > 0 ? feedback : ['Password meets all requirements']
    };
  }

  /**
   * Check if password is in common passwords list
   * @param {string} password - Password to check
   * @returns {boolean} True if password is common
   */
  static isCommonPassword(password) {
    const commonPasswords = [
      'password', 'password123', '123456', '12345678', 'qwerty',
      'abc123', 'monkey', '1234567', 'letmein', 'trustno1',
      'dragon', 'baseball', 'iloveyou', 'master', 'sunshine',
      'ashley', 'bailey', 'passw0rd', 'shadow', '123123',
      'password1', 'admin', 'welcome', 'login', 'root',
      'qwerty123', 'password1234', '12345', '123456789'
    ];

    return commonPasswords.includes(password.toLowerCase());
  }

  /**
   * Generate a secure random token for password reset
   * @param {number} length - Token length in bytes (default: 32)
   * @returns {string} Hex-encoded token
   */
  static generateSecureToken(length = 32) {
    return crypto.randomBytes(length).toString('hex');
  }

  /**
   * Hash a token for secure storage (for reset tokens)
   * @param {string} token - Token to hash
   * @returns {string} SHA256 hash of token
   */
  static hashToken(token) {
    return crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');
  }

  /**
   * Check if user's password is in their password history
   * @param {string} userId - User ID
   * @param {string} newPassword - New password to check
   * @param {number} historyLimit - Number of previous passwords to check (default: 5)
   * @returns {Promise<boolean>} True if password was used before
   */
  static async isPasswordInHistory(userId, newPassword, historyLimit = 5) {
    try {
      // Get user's password history
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: {
          passwordHash: true,
          passwordHistory: true
        }
      });

      if (!user) {
        return false;
      }

      // Check current password
      const matchesCurrent = await this.verify(newPassword, user.passwordHash);
      if (matchesCurrent) {
        return true;
      }

      // Check password history (if field exists)
      if (user.passwordHistory && Array.isArray(user.passwordHistory)) {
        const recentPasswords = user.passwordHistory.slice(0, historyLimit);

        for (const oldHash of recentPasswords) {
          const matchesOld = await this.verify(newPassword, oldHash);
          if (matchesOld) {
            return true;
          }
        }
      }

      return false;
    } catch (error) {
      console.error('Error checking password history:', error);
      // If there's an error, allow the password change
      return false;
    }
  }

  /**
   * Update user's password and maintain history
   * @param {string} userId - User ID
   * @param {string} newPassword - New password (plain text)
   * @param {number} historyLimit - Number of passwords to keep in history
   * @returns {Promise<Object>} Update result
   */
  static async updatePasswordWithHistory(userId, newPassword, historyLimit = 5) {
    try {
      // Get current user
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: {
          passwordHash: true,
          passwordHistory: true
        }
      });

      if (!user) {
        throw new Error('User not found');
      }

      // Validate new password strength
      const validation = this.validateStrength(newPassword);
      if (!validation.isValid) {
        throw new Error(`Password validation failed: ${validation.feedback.join(', ')}`);
      }

      // Check password history
      const isReused = await this.isPasswordInHistory(userId, newPassword, historyLimit);
      if (isReused) {
        throw new Error(`Password has been used recently. Please choose a different password.`);
      }

      // Hash new password
      const newHash = await this.hash(newPassword);

      // Update password history
      const currentHistory = Array.isArray(user.passwordHistory) ? user.passwordHistory : [];
      const updatedHistory = [user.passwordHash, ...currentHistory].slice(0, historyLimit);

      // Update user password
      await prisma.user.update({
        where: { id: userId },
        data: {
          passwordHash: newHash,
          passwordHistory: updatedHistory,
          passwordChangedAt: new Date()
        }
      });

      return {
        success: true,
        message: 'Password updated successfully'
      };
    } catch (error) {
      console.error('Error updating password:', error);
      throw error;
    }
  }

  /**
   * Check if account should be locked due to failed login attempts
   * @param {string} userId - User ID
   * @returns {Promise<Object>} Lockout status
   */
  static async checkAccountLockout(userId) {
    try {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: {
          failedLoginAttempts: true,
          accountLockedUntil: true
        }
      });

      if (!user) {
        return { isLocked: false, remainingAttempts: 5 };
      }

      // Check if account is currently locked
      if (user.accountLockedUntil && user.accountLockedUntil > new Date()) {
        const minutesRemaining = Math.ceil(
          (user.accountLockedUntil.getTime() - Date.now()) / (1000 * 60)
        );
        return {
          isLocked: true,
          remainingAttempts: 0,
          lockedUntil: user.accountLockedUntil,
          minutesRemaining
        };
      }

      // Calculate remaining attempts
      const maxAttempts = 5;
      const failedAttempts = user.failedLoginAttempts || 0;
      const remainingAttempts = Math.max(0, maxAttempts - failedAttempts);

      return {
        isLocked: false,
        remainingAttempts,
        failedAttempts
      };
    } catch (error) {
      console.error('Error checking account lockout:', error);
      return { isLocked: false, remainingAttempts: 5 };
    }
  }

  /**
   * Record a failed login attempt
   * @param {string} userId - User ID
   * @returns {Promise<Object>} Updated lockout status
   */
  static async recordFailedLogin(userId) {
    try {
      const user = await prisma.user.findUnique({
        where: { id: userId },
        select: {
          failedLoginAttempts: true
        }
      });

      if (!user) {
        throw new Error('User not found');
      }

      const failedAttempts = (user.failedLoginAttempts || 0) + 1;
      const maxAttempts = 5;
      const lockoutDurationMinutes = 30;

      // Lock account if max attempts reached
      let accountLockedUntil = null;
      if (failedAttempts >= maxAttempts) {
        accountLockedUntil = new Date(Date.now() + lockoutDurationMinutes * 60 * 1000);
      }

      // Update user
      await prisma.user.update({
        where: { id: userId },
        data: {
          failedLoginAttempts: failedAttempts,
          accountLockedUntil
        }
      });

      // Log security event
      await prisma.securityEvent.create({
        data: {
          userId,
          eventType: failedAttempts >= maxAttempts ? 'ACCOUNT_LOCKED' : 'LOGIN_FAILURE',
          severity: failedAttempts >= maxAttempts ? 'CRITICAL' : 'WARNING',
          description: failedAttempts >= maxAttempts
            ? `Account locked after ${failedAttempts} failed login attempts. Locked until ${accountLockedUntil?.toISOString()}`
            : `Failed login attempt ${failedAttempts} of ${maxAttempts}`,
          metadata: {
            failedAttempts,
            accountLocked: !!accountLockedUntil,
            lockedUntil: accountLockedUntil?.toISOString()
          }
        }
      });

      return {
        failedAttempts,
        remainingAttempts: Math.max(0, maxAttempts - failedAttempts),
        isLocked: !!accountLockedUntil,
        lockedUntil: accountLockedUntil
      };
    } catch (error) {
      console.error('Error recording failed login:', error);
      throw error;
    }
  }

  /**
   * Reset failed login attempts after successful login
   * @param {string} userId - User ID
   * @returns {Promise<void>}
   */
  static async resetFailedLoginAttempts(userId) {
    try {
      await prisma.user.update({
        where: { id: userId },
        data: {
          failedLoginAttempts: 0,
          accountLockedUntil: null
        }
      });
    } catch (error) {
      console.error('Error resetting failed login attempts:', error);
      // Don't throw - this is not critical
    }
  }

  /**
   * Generate a time-based one-time password (TOTP) for 2FA
   * @param {string} secret - User's 2FA secret
   * @returns {string} 6-digit TOTP code
   */
  static generateTOTP(secret) {
    // This is a placeholder for future 2FA implementation
    // Would integrate with libraries like 'otplib' or 'speakeasy'
    throw new Error('2FA/TOTP not yet implemented');
  }

  /**
   * Verify a TOTP code
   * @param {string} token - TOTP code to verify
   * @param {string} secret - User's 2FA secret
   * @returns {boolean} True if code is valid
   */
  static verifyTOTP(token, secret) {
    // This is a placeholder for future 2FA implementation
    throw new Error('2FA/TOTP not yet implemented');
  }
}

export default PasswordUtil;
