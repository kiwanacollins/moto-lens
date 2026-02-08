/**
 * Email Service for German Car Medic Authentication
 *
 * Provides email functionality using Nodemailer with Gmail SMTP.
 *
 * Features:
 * - Email verification emails
 * - Password reset emails
 * - Account notification emails
 * - Professional HTML templates with German Car Medic branding
 * - Delivery tracking and error handling
 */

import nodemailer from 'nodemailer';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

class EmailService {
  /**
   * Create and configure Nodemailer transporter
   * @returns {Object} Nodemailer transporter
   */
  static createTransporter() {
    return nodemailer.createTransport({
      host: process.env.EMAIL_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.EMAIL_PORT) || 587,
      secure: process.env.EMAIL_SECURE === 'true',
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASSWORD
      }
    });
  }

  /**
   * Send email verification link to user
   * @param {Object} user - User object from database
   * @param {string} token - Verification token
   * @returns {Promise<Object>} Email send result
   */
  static async sendVerificationEmail(user, token) {
    try {
      const verificationUrl = `${process.env.FRONTEND_URL}/verify-email?token=${token}`;

      const html = this.generateEmailTemplate('verification', {
        userName: user.firstName || user.email,
        verificationUrl,
        expiryHours: 24
      });

      const transporter = this.createTransporter();

      const info = await transporter.sendMail({
        from: process.env.EMAIL_FROM || 'German Car Medic <noreply@germancarmedic.com>',
        to: user.email,
        subject: 'Verify Your German Car Medic Account',
        html,
        text: `Your German Car Medic account is almost ready. Please verify your email by visiting: ${verificationUrl}`
      });

      // Log email delivery
      await this.logEmailDelivery({
        userId: user.id,
        emailType: 'VERIFICATION',
        recipient: user.email,
        messageId: info.messageId,
        status: 'SENT'
      });

      return {
        success: true,
        messageId: info.messageId,
        message: 'Verification email sent successfully'
      };
    } catch (error) {
      console.error('Error sending verification email:', error);

      // Log failed delivery
      await this.logEmailDelivery({
        userId: user.id,
        emailType: 'VERIFICATION',
        recipient: user.email,
        status: 'FAILED',
        error: error.message
      });

      throw new Error('Failed to send verification email');
    }
  }

  /**   * Send password reset email with OTP code
   * @param {Object} user - User object from database
   * @param {string} otp - 6-digit OTP code
   * @returns {Promise<Object>} Email send result
   */
  static async sendPasswordResetOTP(user, otp) {
    try {
      const html = `
        <!DOCTYPE html>
        <html>
        <head>
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
            .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
            .otp-code { font-size: 32px; font-weight: bold; letter-spacing: 8px; color: #667eea; text-align: center; padding: 20px; background: white; border-radius: 8px; margin: 20px 0; }
            .warning { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
            .footer { text-align: center; margin-top: 20px; color: #666; font-size: 12px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>🔐 Password Reset OTP</h1>
            </div>
            <div class="content">
              <p>Hi ${user.firstName || user.email},</p>
              <p>You requested to reset your password for German Car Medic. Use the OTP code below to complete the process:</p>
              
              <div class="otp-code">${otp}</div>
              
              <p style="text-align: center; color: #666;">This code will expire in <strong>15 minutes</strong></p>
              
              <div class="warning">
                <strong>⚠️ Security Notice:</strong><br>
                • Never share this code with anyone<br>
                • German Car Medic will never ask for this code<br>
                • If you didn't request this, please ignore this email
              </div>
              
              <p>If you didn't request a password reset, you can safely ignore this email.</p>
              
              <p>Best regards,<br><strong>German Car Medic Team</strong></p>
            </div>
            <div class="footer">
              <p>© ${new Date().getFullYear()} German Car Medic. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `;

      const transporter = this.createTransporter();

      const info = await transporter.sendMail({
        from: process.env.EMAIL_FROM || 'German Car Medic <noreply@germancarmedic.com>',
        to: user.email,
        subject: 'Your Password Reset Code - German Car Medic',
        html,
        text: `Your password reset code is: ${otp}\n\nThis code will expire in 15 minutes.\n\nIf you didn't request this, please ignore this email.`
      });

      // Log email delivery
      await this.logEmailDelivery({
        userId: user.id,
        emailType: 'PASSWORD_RESET_OTP',
        recipient: user.email,
        messageId: info.messageId,
        status: 'SENT'
      });

      return {
        success: true,
        messageId: info.messageId,
        message: 'Password reset OTP sent successfully'
      };
    } catch (error) {
      console.error('Error sending password reset OTP:', error);

      // Log failed delivery
      await this.logEmailDelivery({
        userId: user.id,
        emailType: 'PASSWORD_RESET_OTP',
        recipient: user.email,
        status: 'FAILED',
        error: error.message
      });

      throw new Error('Failed to send password reset OTP');
    }
  }

  /**   * Send password reset link to user
   * @param {Object} user - User object from database
   * @param {string} token - Password reset token
   * @returns {Promise<Object>} Email send result
   */
  static async sendPasswordResetEmail(user, token) {
    try {
      const resetUrl = `${process.env.FRONTEND_URL}/reset-password?token=${token}`;

      const html = this.generateEmailTemplate('passwordReset', {
        userName: user.firstName || user.email,
        resetUrl,
        expiryHours: 1
      });

      const transporter = this.createTransporter();

      const info = await transporter.sendMail({
        from: process.env.EMAIL_FROM || 'German Car Medic <noreply@germancarmedic.com>',
        to: user.email,
        subject: 'Reset Your German Car Medic Password',
        html,
        text: `You requested a password reset. Click here to reset: ${resetUrl}`
      });

      // Log email delivery
      await this.logEmailDelivery({
        userId: user.id,
        emailType: 'PASSWORD_RESET',
        recipient: user.email,
        messageId: info.messageId,
        status: 'SENT'
      });

      return {
        success: true,
        messageId: info.messageId,
        message: 'Password reset email sent successfully'
      };
    } catch (error) {
      console.error('Error sending password reset email:', error);

      // Log failed delivery
      await this.logEmailDelivery({
        userId: user.id,
        emailType: 'PASSWORD_RESET',
        recipient: user.email,
        status: 'FAILED',
        error: error.message
      });

      throw new Error('Failed to send password reset email');
    }
  }

  /**
   * Send password change notification to user
   * @param {Object} user - User object from database
   * @returns {Promise<Object>} Email send result
   */
  static async sendPasswordChangeNotification(user) {
    try {
      const html = this.generateEmailTemplate('passwordChanged', {
        userName: user.firstName || user.email,
        changeDate: new Date().toLocaleString(),
        supportUrl: `${process.env.FRONTEND_URL}/support`
      });

      const transporter = this.createTransporter();

      const info = await transporter.sendMail({
        from: process.env.EMAIL_FROM || 'German Car Medic <noreply@germancarmedic.com>',
        to: user.email,
        subject: 'Your German Car Medic Password Was Changed',
        html,
        text: `Your password was recently changed. If you didn't make this change, contact support immediately.`
      });

      // Log email delivery
      await this.logEmailDelivery({
        userId: user.id,
        emailType: 'PASSWORD_CHANGED',
        recipient: user.email,
        messageId: info.messageId,
        status: 'SENT'
      });

      return {
        success: true,
        messageId: info.messageId,
        message: 'Password change notification sent successfully'
      };
    } catch (error) {
      console.error('Error sending password change notification:', error);

      // Log failed delivery (but don't throw - this is not critical)
      await this.logEmailDelivery({
        userId: user.id,
        emailType: 'PASSWORD_CHANGED',
        recipient: user.email,
        status: 'FAILED',
        error: error.message
      });

      // Don't throw - password change was successful, email is just notification
      return {
        success: false,
        message: 'Failed to send notification email'
      };
    }
  }

  /**
   * Send login notification to user (for new device or suspicious login)
   * @param {Object} user - User object from database
   * @param {Object} deviceInfo - Device and location information
   * @returns {Promise<Object>} Email send result
   */
  static async sendLoginNotification(user, deviceInfo) {
    try {
      const html = this.generateEmailTemplate('loginNotification', {
        userName: user.firstName || user.email,
        loginDate: new Date().toLocaleString(),
        deviceInfo: deviceInfo.userAgent || 'Unknown device',
        ipAddress: deviceInfo.ipAddress || 'Unknown',
        location: deviceInfo.location || 'Unknown location'
      });

      const transporter = this.createTransporter();

      const info = await transporter.sendMail({
        from: process.env.EMAIL_FROM || 'German Car Medic <noreply@germancarmedic.com>',
        to: user.email,
        subject: 'New Login to Your German Car Medic Account',
        html,
        text: `A new login was detected on your account from ${deviceInfo.ipAddress || 'unknown IP'}.`
      });

      // Log email delivery
      await this.logEmailDelivery({
        userId: user.id,
        emailType: 'LOGIN_NOTIFICATION',
        recipient: user.email,
        messageId: info.messageId,
        status: 'SENT'
      });

      return {
        success: true,
        messageId: info.messageId,
        message: 'Login notification sent successfully'
      };
    } catch (error) {
      console.error('Error sending login notification:', error);

      // Log failed delivery (but don't throw - login was successful)
      await this.logEmailDelivery({
        userId: user.id,
        emailType: 'LOGIN_NOTIFICATION',
        recipient: user.email,
        status: 'FAILED',
        error: error.message
      });

      return {
        success: false,
        message: 'Failed to send login notification'
      };
    }
  }

  /**
   * Generate HTML email template with German Car Medic branding
   * @param {string} type - Template type (verification, passwordReset, etc.)
   * @param {Object} data - Template data
   * @returns {string} HTML email template
   */
  static generateEmailTemplate(type, data) {
    const baseStyle = `
      <style>
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
          line-height: 1.6;
          color: #333;
          max-width: 600px;
          margin: 0 auto;
          padding: 20px;
        }
        .header {
          background: linear-gradient(135deg, #0ea5e9 0%, #0284c7 100%);
          color: white;
          padding: 30px;
          text-align: center;
          border-radius: 8px 8px 0 0;
        }
        .logo {
          font-size: 32px;
          font-weight: bold;
          margin: 0;
        }
        .content {
          background: white;
          padding: 30px;
          border: 1px solid #e5e7eb;
          border-top: none;
        }
        .button {
          display: inline-block;
          background: #0ea5e9;
          color: white;
          padding: 14px 28px;
          text-decoration: none;
          border-radius: 6px;
          font-weight: 600;
          margin: 20px 0;
        }
        .footer {
          text-align: center;
          color: #6b7280;
          font-size: 14px;
          padding: 20px;
          border-top: 1px solid #e5e7eb;
        }
        .warning {
          background: #fef3c7;
          border-left: 4px solid #f59e0b;
          padding: 15px;
          margin: 20px 0;
        }
        .info {
          background: #f0f9ff;
          border-left: 4px solid #0ea5e9;
          padding: 15px;
          margin: 20px 0;
        }
      </style>
    `;

    const templates = {
      verification: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          ${baseStyle}
        </head>
        <body>
          <div class="header">
            <h1 class="logo">🔧 German Car Medic</h1>
            <p>Your Diagnostic Assistant</p>
          </div>
          <div class="content">
            <h2>Welcome, ${data.userName}!</h2>
            <p>Your German Car Medic account is almost ready.</p>
            <p>Please verify your email address by clicking the button below to get started:</p>
            <center>
              <a href="${data.verificationUrl}" class="button">Verify Email Address</a>
            </center>
            <div class="info">
              <strong>Why verify?</strong>
              <ul>
                <li>Secure your account</li>
                <li>Access all diagnostic features</li>
                <li>Receive important updates</li>
              </ul>
            </div>
            <p>This link will expire in ${data.expiryHours} hours.</p>
            <p>If you didn't create this account, you can safely ignore this email.</p>
          </div>
          <div class="footer">
            <p>© 2026 German Car Medic. All rights reserved.</p>
            <p>You're receiving this because you signed up for German Car Medic.</p>
          </div>
        </body>
        </html>
      `,

      passwordReset: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          ${baseStyle}
        </head>
        <body>
          <div class="header">
            <h1 class="logo">🔧 German Car Medic</h1>
            <p>Your Diagnostic Assistant</p>
          </div>
          <div class="content">
            <h2>Reset Your Password</h2>
            <p>Hi ${data.userName},</p>
            <p>A request was made to reset your password. Click the button below to create a new one:</p>
            <center>
              <a href="${data.resetUrl}" class="button">Reset Password</a>
            </center>
            <div class="warning">
              <strong>⚠️ Security Notice</strong>
              <p>This link will expire in ${data.expiryHours} hour(s) for your security.</p>
              <p>If you didn't request a password reset, please ignore this email or contact support if you're concerned.</p>
            </div>
            <p><strong>Didn't request this?</strong> Your account is still secure. Someone may have entered your email by mistake.</p>
          </div>
          <div class="footer">
            <p>© 2026 German Car Medic. All rights reserved.</p>
            <p>Never share your password or reset link with anyone.</p>
          </div>
        </body>
        </html>
      `,

      passwordChanged: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          ${baseStyle}
        </head>
        <body>
          <div class="header">
            <h1 class="logo">🔧 German Car Medic</h1>
            <p>Your Diagnostic Assistant</p>
          </div>
          <div class="content">
            <h2>Your Password Was Changed</h2>
            <p>Hi ${data.userName},</p>
            <p>Your password was successfully changed on ${data.changeDate}.</p>
            <div class="info">
              <strong>✅ Your account is secure</strong>
              <p>If you made this change, no further action is needed.</p>
            </div>
            <div class="warning">
              <strong>⚠️ Didn't make this change?</strong>
              <p>If you didn't change your password, your account may be compromised.</p>
              <p><strong>Take action immediately:</strong></p>
              <ol>
                <li>Reset your password using the "Forgot Password" link</li>
                <li>Review recent account activity</li>
                <li>Contact our support team</li>
              </ol>
              <center>
                <a href="${data.supportUrl}" class="button">Contact Support</a>
              </center>
            </div>
          </div>
          <div class="footer">
            <p>© 2026 German Car Medic. All rights reserved.</p>
            <p>This is an automated security notification.</p>
          </div>
        </body>
        </html>
      `,

      loginNotification: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          ${baseStyle}
        </head>
        <body>
          <div class="header">
            <h1 class="logo">🔧 German Car Medic</h1>
            <p>Your Diagnostic Assistant</p>
          </div>
          <div class="content">
            <h2>New Login Detected</h2>
            <p>Hi ${data.userName},</p>
            <p>A new login to your account was detected. Here are the details:</p>
            <div class="info">
              <strong>Login Information</strong>
              <ul>
                <li><strong>Date & Time:</strong> ${data.loginDate}</li>
                <li><strong>Device:</strong> ${data.deviceInfo}</li>
                <li><strong>IP Address:</strong> ${data.ipAddress}</li>
                <li><strong>Location:</strong> ${data.location}</li>
              </ul>
            </div>
            <p><strong>Was this you?</strong> If you recognize this activity, you can safely ignore this email.</p>
            <div class="warning">
              <strong>⚠️ Don't recognize this login?</strong>
              <p>If this wasn't you, someone may have accessed your account.</p>
              <p><strong>Secure your account now:</strong></p>
              <ol>
                <li>Change your password immediately</li>
                <li>Review active sessions and log out of unfamiliar devices</li>
                <li>Contact support if you need help</li>
              </ol>
            </div>
          </div>
          <div class="footer">
            <p>© 2026 German Car Medic. All rights reserved.</p>
            <p>This is an automated security notification.</p>
          </div>
        </body>
        </html>
      `
    };

    return templates[type] || templates.verification;
  }

  /**
   * Log email delivery to database for tracking
   * @param {Object} data - Email delivery data
   * @returns {Promise<void>}
   */
  static async logEmailDelivery(data) {
    try {
      // Log to security events for tracking
      await prisma.securityEvent.create({
        data: {
          userId: data.userId,
          eventType: 'EMAIL_VERIFIED',
          severity: data.status === 'FAILED' ? 'WARNING' : 'INFO',
          description: `Email ${data.emailType} ${data.status}: ${data.recipient}`,
          metadata: {
            recipient: data.recipient,
            messageId: data.messageId,
            status: data.status,
            error: data.error,
            timestamp: new Date().toISOString()
          }
        }
      });
    } catch (error) {
      console.error('Error logging email delivery:', error);
      // Don't throw - email logging is not critical
    }
  }

  /**
   * Validate email delivery (check if email was sent successfully)
   * @param {string} messageId - Email message ID
   * @returns {Promise<Object>} Delivery status
   */
  static async validateEmailDelivery(messageId) {
    try {
      // Check if email was logged in security events
      const event = await prisma.securityEvent.findFirst({
        where: {
          details: {
            path: ['messageId'],
            equals: messageId
          }
        }
      });

      if (!event) {
        return {
          success: false,
          status: 'UNKNOWN',
          message: 'Email delivery status not found'
        };
      }

      return {
        success: event.details.status === 'SENT',
        status: event.details.status,
        messageId,
        sentAt: event.createdAt
      };
    } catch (error) {
      console.error('Error validating email delivery:', error);
      return {
        success: false,
        status: 'ERROR',
        message: 'Failed to validate email delivery'
      };
    }
  }

  /**
   * Test email configuration
   * @returns {Promise<boolean>} True if configuration is valid
   */
  static async testConnection() {
    try {
      const transporter = this.createTransporter();
      await transporter.verify();
      return true;
    } catch (error) {
      console.error('Email configuration test failed:', error);
      return false;
    }
  }
}

export default EmailService;
