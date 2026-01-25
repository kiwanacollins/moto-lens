#!/bin/bash

# MotoLens VPS Initial Setup Script
# Run this script on your VPS (207.180.249.87) as root
# Usage: bash vps-setup.sh

set -e

echo "🚀 MotoLens VPS Setup Script"
echo "============================"

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install Node.js 20.x
echo "📦 Installing Node.js 20.x..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Verify Node installation
node --version
npm --version

# Install PM2 globally
echo "📦 Installing PM2 process manager..."
npm install -g pm2

# Install Nginx
echo "📦 Installing Nginx..."
apt install -y nginx

# Install Git
echo "📦 Installing Git..."
apt install -y git

# Create app user (optional but recommended)
echo "👤 Creating moto-lens user..."
useradd -m -s /bin/bash motolens || echo "User already exists"

# Create app directory
echo "📁 Creating application directory..."
mkdir -p /var/www/moto-lens
chown -R motolens:motolens /var/www/moto-lens

# Setup firewall
echo "🔥 Configuring firewall..."
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw allow 3001  # Backend API port (remove this after nginx is configured)
ufw --force enable

# Enable services
echo "⚙️ Enabling services..."
systemctl enable nginx
systemctl start nginx

echo ""
echo "✅ VPS setup complete!"
echo ""
echo "Next steps:"
echo "1. Clone the repository: cd /var/www/moto-lens && git clone https://github.com/kiwanacollins/moto-lens.git ."
echo "2. Setup backend: cd backend && npm install"
echo "3. Create .env file: cp .env.production.example .env && nano .env"
echo "4. Start with PM2: pm2 start ecosystem.config.cjs --env production"
echo "5. Configure Nginx: cp /path/to/nginx.conf /etc/nginx/sites-available/moto-lens"
echo "6. Enable site: ln -s /etc/nginx/sites-available/moto-lens /etc/nginx/sites-enabled/"
echo "7. Test & reload: nginx -t && systemctl reload nginx"
