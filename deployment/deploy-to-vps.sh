#!/bin/bash
# MotoLens Backend Deployment Script
# Run this script ON YOUR VPS as user 'kiwana'
# 
# Usage:
#   1. SSH into your VPS: ssh kiwana@207.180.249.87
#   2. Run: bash <(curl -s https://raw.githubusercontent.com/kiwanacollins/moto-lens/main/deployment/deploy-to-vps.sh)

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          MotoLens Backend Deployment to VPS                    ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Configuration
APP_DIR="/home/kiwana/moto-lens"
BACKEND_DIR="$APP_DIR/backend"

# Check if running as kiwana user
if [ "$USER" != "kiwana" ]; then
    echo "⚠️  Warning: This script should be run as user 'kiwana'"
    echo "Current user: $USER"
fi

# Step 1: Check prerequisites
echo "📋 Checking prerequisites..."

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed"
    echo "Please install Node.js 20.x first:"
    echo "  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -"
    echo "  sudo apt install -y nodejs"
    exit 1
fi
echo "✅ Node.js $(node --version)"

# Check npm
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed"
    exit 1
fi
echo "✅ npm $(npm --version)"

# Check PM2
if ! command -v pm2 &> /dev/null; then
    echo "⚠️  PM2 is not installed. Installing..."
    sudo npm install -g pm2
fi
echo "✅ PM2 $(pm2 --version)"

# Check Git
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed"
    echo "Please install: sudo apt install -y git"
    exit 1
fi
echo "✅ Git $(git --version | head -n1)"

echo ""

# Step 2: Clone or update repository
if [ -d "$APP_DIR/.git" ]; then
    echo "📥 Repository already exists. Pulling latest changes..."
    cd "$APP_DIR"
    git pull origin main
else
    echo "📥 Cloning repository..."
    mkdir -p "$(dirname "$APP_DIR")"
    git clone https://github.com/kiwanacollins/moto-lens.git "$APP_DIR"
    cd "$APP_DIR"
fi

echo ""

# Step 3: Install backend dependencies
echo "📦 Installing backend dependencies..."
cd "$BACKEND_DIR"
npm install --production

echo ""

# Step 4: Setup environment file
echo "🔧 Setting up environment file..."

if [ -f "$BACKEND_DIR/.env" ]; then
    echo "⚠️  .env file already exists. Backing up to .env.backup"
    cp "$BACKEND_DIR/.env" "$BACKEND_DIR/.env.backup"
fi

# Create .env file with placeholders
cat > "$BACKEND_DIR/.env" << 'ENVFILE'
# MotoLens Backend - Production Environment
PORT=3001
NODE_ENV=production
FRONTEND_URL=https://moto-lens.vercel.app,https://moto-lens-*.vercel.app,http://localhost:5173

# API Keys - UPDATE THESE WITH YOUR ACTUAL KEYS
AUTODEV_API_KEY=your_autodev_key_here
GEMINI_API_KEY=your_gemini_key_here
SERPAPI_KEY=your_serpapi_key_here
ENVFILE

echo "✅ .env file created at: $BACKEND_DIR/.env"
echo ""
echo "⚠️  IMPORTANT: You need to edit .env and add your API keys!"
echo "   Run: nano $BACKEND_DIR/.env"
echo ""

# Ask if user wants to edit now
read -p "Do you want to edit the .env file now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    nano "$BACKEND_DIR/.env"
fi

echo ""

# Step 5: Create logs directory
echo "📁 Creating logs directory..."
mkdir -p "$BACKEND_DIR/logs"

echo ""

# Step 6: Start with PM2
echo "🚀 Starting backend with PM2..."

# Check if already running
if pm2 describe moto-lens-api &>/dev/null; then
    echo "⚠️  Application already running. Restarting..."
    pm2 restart moto-lens-api
else
    echo "Starting fresh instance..."
    cd "$BACKEND_DIR"
    pm2 start ecosystem.config.cjs --env production
fi

# Save PM2 configuration
pm2 save

# Setup PM2 startup (if not already done)
if ! systemctl is-enabled pm2-kiwana &>/dev/null; then
    echo "🔧 Setting up PM2 auto-start on boot..."
    pm2 startup
fi

echo ""

# Step 7: Check status
echo "📊 Application Status:"
pm2 status

echo ""
echo "📋 Recent Logs:"
pm2 logs moto-lens-api --lines 20 --nostream

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "✅ Backend Deployment Complete!"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "🧪 Test the backend:"
echo "   curl http://localhost:3001/api/health"
echo ""
echo "📋 View logs:"
echo "   pm2 logs moto-lens-api"
echo ""
echo "🔄 Restart backend:"
echo "   pm2 restart moto-lens-api"
echo ""
echo "📊 Monitor:"
echo "   pm2 monit"
echo ""
echo "⚠️  Next Steps:"
echo "   1. If you haven't already, configure Nginx as reverse proxy"
echo "   2. Test from outside: curl http://207.180.249.87/api/health"
echo "   3. Deploy frontend to Vercel"
echo "   4. Update backend CORS with your Vercel URL"
echo ""
