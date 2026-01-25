#!/bin/bash

# MotoLens Quick Deployment Script
# This script helps verify your local setup before deployment

set -e

echo "🔍 MotoLens Pre-Deployment Verification"
echo "========================================"
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: Run this script from the project root directory"
    exit 1
fi

# Check git status
echo "📋 Git Status:"
git status --short
echo ""

# Check if there are uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Warning: You have uncommitted changes"
    read -p "Do you want to continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Build frontend to verify it works
echo "🏗️  Building frontend..."
cd frontend
npm run build
echo "✅ Frontend build successful"
echo ""
cd ..

# Check backend dependencies
echo "📦 Checking backend dependencies..."
cd backend
if [ ! -d "node_modules" ]; then
    echo "⚠️  Installing backend dependencies..."
    npm install
fi
echo "✅ Backend dependencies OK"
cd ..

# Display deployment URLs
echo ""
echo "📍 Deployment Configuration:"
echo "   Backend VPS: 207.180.249.87"
echo "   Frontend: Vercel (auto-deploy on git push)"
echo ""

# Check if API keys are documented
echo "🔑 Required API Keys (check DEPLOYMENT_CHECKLIST.md):"
echo "   - AUTODEV_API_KEY"
echo "   - GEMINI_API_KEY"
echo "   - SERPAPI_KEY"
echo ""

# Show backend .env.production.example
if [ -f "backend/.env.production.example" ]; then
    echo "📄 Backend environment template ready: backend/.env.production.example"
else
    echo "⚠️  Warning: backend/.env.production.example not found"
fi

# Check frontend environment
if [ -f "frontend/.env.production" ]; then
    echo "📄 Frontend production environment ready: frontend/.env.production"
else
    echo "⚠️  Warning: frontend/.env.production not found"
fi

echo ""
echo "✅ Pre-deployment verification complete!"
echo ""
echo "📚 Next Steps:"
echo "1. Review DEPLOYMENT_CHECKLIST.md"
echo "2. Push to GitHub: git push origin main"
echo "3. Deploy backend to VPS (follow checklist)"
echo "4. Deploy frontend to Vercel (automatic after git push)"
echo ""
