#!/bin/bash

# MotoLens Backend Deployment Script
# Run this on your VPS to deploy/update the backend
# Usage: bash deploy-backend.sh

set -e

APP_DIR="/var/www/moto-lens"
BACKEND_DIR="$APP_DIR/backend"

echo "🚀 Deploying MotoLens Backend..."

# Navigate to app directory
cd $APP_DIR

# Pull latest changes
echo "📥 Pulling latest changes..."
git pull origin main

# Navigate to backend
cd $BACKEND_DIR

# Install dependencies
echo "📦 Installing dependencies..."
npm install --production

# Create logs directory
mkdir -p logs

# Restart application with PM2
echo "🔄 Restarting application..."
pm2 restart ecosystem.config.cjs --env production || pm2 start ecosystem.config.cjs --env production

# Save PM2 process list
pm2 save

echo ""
echo "✅ Backend deployment complete!"
echo ""
echo "📊 Check status: pm2 status"
echo "📋 View logs: pm2 logs moto-lens-api"
