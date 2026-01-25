#!/bin/bash

# MotoLens Backend - Quick Deployment Commands
# Run these commands on your VPS at 207.180.249.87 as user 'kiwana'

# =============================================================================
# INITIAL SETUP (Run once)
# =============================================================================

# 1. Create directory and clone repository
mkdir -p /home/kiwana/moto-lens
cd /home/kiwana/moto-lens
git clone https://github.com/kiwanacollins/moto-lens.git .

# 2. Install backend dependencies
cd /home/kiwana/moto-lens/backend
npm install --production

# 3. Create environment file
cp .env.production.example .env
nano .env  # Edit with your API keys

# 4. Create logs directory
mkdir -p logs

# 5. Start with PM2
pm2 start ecosystem.config.cjs --env production
pm2 save
pm2 startup  # Follow instructions to enable auto-start

# 6. Configure Nginx (as root or with sudo)
sudo cp /home/kiwana/moto-lens/deployment/nginx.conf /etc/nginx/sites-available/moto-lens
sudo ln -s /etc/nginx/sites-available/moto-lens /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

# 7. Test
curl http://localhost:3001/api/health
curl http://207.180.249.87/api/health

# =============================================================================
# UPDATE BACKEND (Run when updating code)
# =============================================================================

cd /home/kiwana/moto-lens
git pull origin main
cd backend
npm install --production
pm2 restart moto-lens-api

# =============================================================================
# MONITORING COMMANDS
# =============================================================================

# Check status
pm2 status

# View logs
pm2 logs moto-lens-api

# View last 50 lines
pm2 logs moto-lens-api --lines 50

# Real-time monitoring
pm2 monit

# Restart application
pm2 restart moto-lens-api

# Stop application
pm2 stop moto-lens-api

# Delete from PM2
pm2 delete moto-lens-api

# =============================================================================
# TROUBLESHOOTING
# =============================================================================

# Check if port 3001 is in use
netstat -tlnp | grep 3001

# Check Nginx status
sudo systemctl status nginx

# Test Nginx config
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx

# View Nginx error logs
sudo tail -f /var/log/nginx/error.log

# Check backend logs
cd /home/kiwana/moto-lens/backend
tail -f logs/combined.log
tail -f logs/error.log

# =============================================================================
# ENVIRONMENT VARIABLES (.env file location)
# =============================================================================

# Edit environment variables
nano /home/kiwana/moto-lens/backend/.env

# Required variables:
# PORT=3001
# NODE_ENV=production
# FRONTEND_URL=https://moto-lens.vercel.app,https://moto-lens-*.vercel.app
# AUTODEV_API_KEY=your_key
# GEMINI_API_KEY=your_key
# SERPAPI_KEY=your_key

# After changing .env, restart:
pm2 restart moto-lens-api
