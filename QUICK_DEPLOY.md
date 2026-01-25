# MotoLens Deployment - Quick Start Guide

## 🎯 Overview

This guide helps you deploy MotoLens with:
- **Frontend**: Vercel (React/Vite PWA)
- **Backend**: Contabo VPS at `207.180.249.87` (Node.js/Express API)

---

## ⚡ Quick Start (TL;DR)

### 1. Backend (VPS) - One-Time Setup
```bash
# On VPS (207.180.249.87)
ssh kiwana@207.180.249.87
bash <(curl -s https://raw.githubusercontent.com/kiwanacollins/moto-lens/main/deployment/vps-setup.sh)
```

### 2. Configure & Start Backend
```bash
# Edit .env with your API keys
nano /home/kiwana/moto-lens/backend/.env

# Start application
cd /home/kiwana/moto-lens/backend
pm2 start ecosystem.config.cjs --env production
pm2 save && pm2 startup
```

### 3. Frontend (Vercel) - Auto Deploy
```bash
# Push to GitHub (from local machine)
git push origin main

# Deploy on Vercel dashboard:
# https://vercel.com/new
# Import: kiwanacollins/moto-lens
# Root: frontend
# Framework: Vite
# Env: VITE_API_BASE_URL=http://207.180.249.87/api
```

---

## 📋 Prerequisites

### What You Need

**VPS Requirements:**
- ✅ Contabo VPS at `207.180.249.87`
- ✅ Root SSH access
- ✅ At least 1GB RAM, 10GB storage
- ✅ Ubuntu/Debian OS

**API Keys (get these first!):**
- ✅ `AUTODEV_API_KEY` - For VIN decoding
- ✅ `GEMINI_API_KEY` - For AI-powered part identification
- ✅ `SERPAPI_KEY` - For image search

**GitHub & Vercel:**
- ✅ GitHub account with `kiwanacollins/moto-lens` repository
- ✅ Vercel account (free tier works)
- ✅ Vercel connected to GitHub

---

## 🚀 Detailed Deployment Steps

### Step 1: Prepare Local Environment

```bash
# Verify everything works locally
cd /Users/kiwana/projects/moto-lens

# Run pre-deployment check
bash scripts/pre-deploy-check.sh

# Commit and push if needed
git add .
git commit -m "Ready for production deployment"
git push origin main
```

---

### Step 2: Deploy Backend to VPS

#### 2.1: SSH into VPS
```bash
ssh kiwana@207.180.249.87
```

#### 2.2: Run Setup Script (First Time Only)
```bash
# Download and run VPS setup
cd /tmp
curl -O https://raw.githubusercontent.com/kiwanacollins/moto-lens/main/deployment/vps-setup.sh
bash vps-setup.sh
```

**OR manually run these commands:**
```bash
# Update system
apt update && apt upgrade -y

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Install PM2, Nginx, Git
npm install -g pm2
apt install -y nginx git

# Configure firewall
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable

# Clone repository
mkdir -p /home/kiwana/moto-lens
cd /home/kiwana/moto-lens
git clone https://github.com/kiwanacollins/moto-lens.git .

# Install backend dependencies
cd backend
npm install --production
```

#### 2.3: Configure Environment Variables
```bash
# Create .env file
nano /home/kiwana/moto-lens/backend/.env
```

**Paste and update with your API keys:**
```env
PORT=3001
NODE_ENV=production
FRONTEND_URL=https://moto-lens.vercel.app,https://moto-lens-*.vercel.app,http://localhost:5173

# YOUR ACTUAL API KEYS HERE
AUTODEV_API_KEY=your_autodev_api_key_here
GEMINI_API_KEY=your_gemini_api_key_here
SERPAPI_KEY=your_serpapi_key_here
```

Save: `Ctrl+X`, then `Y`, then `Enter`

#### 2.4: Start Backend with PM2
```bash
cd /home/kiwana/moto-lens/backend
mkdir -p logs
pm2 start ecosystem.config.cjs --env production
pm2 save
pm2 startup
pm2 status
```

#### 2.5: Configure Nginx
```bash
# Copy nginx config
cp /home/kiwana/moto-lens/deployment/nginx.conf /etc/nginx/sites-available/moto-lens

# Enable site
ln -s /etc/nginx/sites-available/moto-lens /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test and reload
nginx -t
systemctl reload nginx
```

#### 2.6: Test Backend
```bash
# Test locally
curl http://localhost:3001/api/health

# Test via Nginx
curl http://207.180.249.87/api/health
```

**Expected Response:**
```json
{"status":"ok","message":"MotoLens API is running","timestamp":"..."}
```

✅ **Backend Deployed!**

---

### Step 3: Deploy Frontend to Vercel

#### 3.1: Access Vercel Dashboard
1. Go to: https://vercel.com/new
2. Sign in with GitHub
3. Click "Import Project"

#### 3.2: Import Repository
1. Select repository: `kiwanacollins/moto-lens`
2. Click "Import"

#### 3.3: Configure Project
- **Framework Preset**: `Vite`
- **Root Directory**: `frontend`
- **Build Command**: `npm run build`
- **Output Directory**: `dist`
- **Install Command**: `npm install`

#### 3.4: Add Environment Variable
Click "Environment Variables":
- **Key**: `VITE_API_BASE_URL`
- **Value**: `http://207.180.249.87/api`

Click "Add"

#### 3.5: Deploy
1. Click "Deploy"
2. Wait for build to complete (~2-3 minutes)
3. Your app will be live at: `https://moto-lens.vercel.app`

✅ **Frontend Deployed!**

---

### Step 4: Connect Frontend & Backend

#### 4.1: Get Your Vercel URL
After deployment, copy your Vercel URL (e.g., `https://moto-lens.vercel.app`)

#### 4.2: Update Backend CORS
```bash
# SSH back to VPS
ssh kiwana@207.180.249.87

# Edit backend .env
nano /home/kiwana/moto-lens/backend/.env
```

**Update FRONTEND_URL with your actual Vercel URL:**
```env
FRONTEND_URL=https://moto-lens.vercel.app,https://moto-lens-*.vercel.app,http://localhost:5173
```

**Restart backend:**
```bash
cd /home/kiwana/moto-lens/backend
pm2 restart moto-lens-api
pm2 logs moto-lens-api
```

---

### Step 5: Verify Deployment

#### Test Checklist:
- [ ] Visit your Vercel URL: `https://moto-lens.vercel.app`
- [ ] Test VIN decoder with a German vehicle VIN
- [ ] Check browser console for errors (should be clean)
- [ ] Test image search functionality
- [ ] Test part identification
- [ ] Try installing PWA on mobile device

**Backend Health Check:**
```bash
curl http://207.180.249.87/api/health
```

---

## 🔧 Maintenance & Updates

### Update Backend Code
```bash
ssh kiwana@207.180.249.87
cd /home/kiwana/moto-lens
git pull origin main
cd backend
npm install --production
pm2 restart moto-lens-api
```

**Or use the deploy script:**
```bash
bash /home/kiwana/moto-lens/deployment/deploy-backend.sh
```

### Update Frontend
Just push to GitHub - Vercel auto-deploys:
```bash
git push origin main
```

### Monitor Backend
```bash
# Check status
pm2 status

# View logs
pm2 logs moto-lens-api

# Real-time monitoring
pm2 monit

# Restart if needed
pm2 restart moto-lens-api
```

---

## 🐛 Troubleshooting

### CORS Errors in Browser
**Problem**: "Access to XMLHttpRequest has been blocked by CORS policy"

**Solution:**
```bash
ssh kiwana@207.180.249.87
nano /home/kiwana/moto-lens/backend/.env
# Ensure FRONTEND_URL matches your Vercel URL exactly
pm2 restart moto-lens-api
```

### Backend Not Responding
```bash
# Check PM2 status
pm2 status

# Check logs for errors
pm2 logs moto-lens-api --lines 50

# Check if port is in use
netstat -tlnp | grep 3001

# Check Nginx
systemctl status nginx
nginx -t
```

### Vercel Build Fails
1. Check build logs in Vercel dashboard
2. Verify `frontend/package.json` has all dependencies
3. Ensure `VITE_API_BASE_URL` is set correctly
4. Try local build: `cd frontend && npm run build`

### PM2 Process Died
```bash
# Restart with logs
pm2 restart moto-lens-api
pm2 logs moto-lens-api

# If it keeps dying, check environment
cd /home/kiwana/moto-lens/backend
cat .env  # Verify API keys are set
npm install --production  # Reinstall dependencies
```

---

## 🎯 Quick Commands Reference

| Task | Command |
|------|---------|
| **SSH to VPS** | `ssh kiwana@207.180.249.87` |
| **Backend status** | `pm2 status` |
| **View logs** | `pm2 logs moto-lens-api` |
| **Restart backend** | `pm2 restart moto-lens-api` |
| **Test health** | `curl http://207.180.249.87/api/health` |
| **Update backend** | `cd /home/kiwana/moto-lens && git pull && cd backend && npm install --production && pm2 restart moto-lens-api` |
| **Reload Nginx** | `nginx -t && systemctl reload nginx` |

---

## 📊 Deployment URLs

| Service | URL |
|---------|-----|
| **Frontend (Production)** | https://moto-lens.vercel.app |
| **Backend API** | http://207.180.249.87/api |
| **Health Check** | http://207.180.249.87/api/health |
| **GitHub Repo** | https://github.com/kiwanacollins/moto-lens |
| **Vercel Dashboard** | https://vercel.com/dashboard |

---

## 🔐 Security Notes

1. **Never commit `.env` files** to Git (already in `.gitignore`)
2. **Keep API keys secret** - only store in VPS `.env` and Vercel dashboard
3. **Update VPS regularly**: `apt update && apt upgrade`
4. **Monitor PM2 logs** for suspicious activity
5. **Consider SSL** once you have a domain (see optional section)

---

## 🌐 Optional: Custom Domain & SSL

### Add Custom Domain to Backend

1. **Point DNS A record**: `api.yourdomain.com` → `207.180.249.87`
2. **Install SSL certificate**:
   ```bash
   apt install -y certbot python3-certbot-nginx
   certbot --nginx -d api.yourdomain.com
   ```
3. **Update Vercel environment**:
   - `VITE_API_BASE_URL` = `https://api.yourdomain.com/api`
4. **Update backend CORS**:
   ```bash
   nano /home/kiwana/moto-lens/backend/.env
   # FRONTEND_URL=https://yourdomain.com,https://moto-lens.vercel.app
   pm2 restart moto-lens-api
   ```

### Add Custom Domain to Vercel
1. Go to Vercel dashboard → Project Settings → Domains
2. Add your domain: `yourdomain.com`
3. Follow DNS configuration instructions
4. Vercel auto-provisions SSL

---

## 📞 Support

- **Documentation**: See `DEPLOYMENT.md` for detailed reference
- **Checklist**: See `DEPLOYMENT_CHECKLIST.md` for step-by-step guide
- **Issues**: https://github.com/kiwanacollins/moto-lens/issues

---

## ✅ Post-Deployment Checklist

- [ ] Backend health endpoint responds
- [ ] Frontend loads on Vercel
- [ ] VIN decoder works
- [ ] Image search functional
- [ ] Part identification works
- [ ] No CORS errors in console
- [ ] PWA installable on mobile
- [ ] PM2 auto-restart configured
- [ ] Nginx configured and running
- [ ] Environment variables secured

---

**🎉 Congratulations! Your MotoLens app is now live!**

Frontend: `https://moto-lens.vercel.app`  
Backend: `http://207.180.249.87/api`
