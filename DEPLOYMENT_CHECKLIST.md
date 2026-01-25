# MotoLens Deployment Checklist

## Pre-Deployment Requirements

### VPS Information
- [ ] VPS IP Address: `207.180.249.87`
- [ ] SSH Root Access Confirmed
- [ ] VPS has at least 1GB RAM and 10GB storage

### API Keys Required
- [ ] **AUTODEV_API_KEY**: ________________
- [ ] **GEMINI_API_KEY**: ________________
- [ ] **SERPAPI_KEY**: ________________

### GitHub & Vercel
- [ ] Code pushed to GitHub: `https://github.com/kiwanacollins/moto-lens`
- [ ] Vercel account created/logged in
- [ ] Vercel connected to GitHub account

---

## Phase 1: Backend Deployment (VPS)

### Step 1.1: Initial VPS Setup
```bash
# Connect to VPS
ssh root@207.180.249.87

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
```

**Status**: [ ] Completed

---

### Step 1.2: Clone and Setup Application
```bash
# Create app directory
mkdir -p /home/kiwana/moto-lens
cd /home/kiwana/moto-lens

# Clone repository
git clone https://github.com/kiwanacollins/moto-lens.git .

# Navigate to backend
cd backend

# Install dependencies
npm install --production
```

**Status**: [ ] Completed

---

### Step 1.3: Configure Environment Variables
```bash
# Create .env file
nano /home/kiwana/moto-lens/backend/.env
```

**Paste this content** (replace with your actual API keys):
```env
PORT=3001
NODE_ENV=production
FRONTEND_URL=https://moto-lens.vercel.app,https://moto-lens-*.vercel.app,http://localhost:5173

# Your API Keys
AUTODEV_API_KEY=your_actual_autodev_key
GEMINI_API_KEY=your_actual_gemini_key
SERPAPI_KEY=your_actual_serpapi_key
```

**Status**: [ ] Completed

---

### Step 1.4: Start Backend with PM2
```bash
cd /home/kiwana/moto-lens/backend

# Create logs directory
mkdir -p logs

# Start application
pm2 start ecosystem.config.cjs --env production

# Save PM2 process list (auto-restart on reboot)
pm2 save
pm2 startup

# Check status
pm2 status
pm2 logs moto-lens-api --lines 20
```

**Expected Output**: PM2 should show `moto-lens-api` running in cluster mode

**Status**: [ ] Completed

---

### Step 1.5: Configure Nginx Reverse Proxy
```bash
# Copy nginx config
cp /home/kiwana/moto-lens/deployment/nginx.conf /etc/nginx/sites-available/moto-lens

# Enable site
ln -s /etc/nginx/sites-available/moto-lens /etc/nginx/sites-enabled/

# Remove default site (optional)
rm -f /etc/nginx/sites-enabled/default

# Test configuration
nginx -t

# Reload Nginx
systemctl reload nginx
```

**Status**: [ ] Completed

---

### Step 1.6: Test Backend
```bash
# Test locally on VPS
curl http://localhost:3001/api/health

# Test via Nginx (from another terminal or your local machine)
curl http://207.180.249.87/api/health
```

**Expected Response**:
```json
{
  "status": "ok",
  "message": "MotoLens API is running",
  "timestamp": "2026-01-25T..."
}
```

**Status**: [ ] Completed

---

## Phase 2: Frontend Deployment (Vercel)

### Step 2.1: Ensure Code is Pushed to GitHub
```bash
# From your local machine in project directory
cd /Users/kiwana/projects/moto-lens

# Check git status
git status

# Add, commit, and push if needed
git add .
git commit -m "Ready for production deployment"
git push origin main
```

**Status**: [ ] Completed

---

### Step 2.2: Deploy to Vercel (Web Dashboard)

1. **Go to**: https://vercel.com/new
2. **Click**: "Import Project"
3. **Select**: `kiwanacollins/moto-lens` repository
4. **Configure**:
   - **Framework Preset**: Vite
   - **Root Directory**: `frontend`
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
   - **Install Command**: `npm install`

5. **Environment Variables** (Add these in Vercel):
   - Key: `VITE_API_BASE_URL`
   - Value: `http://207.180.249.87/api`

6. **Click**: "Deploy"

**Status**: [ ] Completed

---

### Step 2.3: Get Your Vercel URL
After deployment completes, Vercel will provide your URL:
- Production URL: `https://moto-lens.vercel.app` (or similar)
- Write it down: ___________________________

**Status**: [ ] Completed

---

## Phase 3: Final Integration

### Step 3.1: Update Backend CORS Settings
```bash
# SSH back to VPS
ssh kiwana@207.180.249.87

# Edit backend .env file
nano /home/kiwana/moto-lens/backend/.env
```

**Update FRONTEND_URL** with your actual Vercel URL:
```env
FRONTEND_URL=https://moto-lens.vercel.app,https://moto-lens-*.vercel.app,http://localhost:5173
```

**Restart backend**:
```bash
cd /home/kiwana/moto-lens/backend
pm2 restart moto-lens-api
pm2 logs moto-lens-api --lines 20
```

**Status**: [ ] Completed

---

### Step 3.2: Test End-to-End

1. **Open**: Your Vercel URL in browser
2. **Test VIN Decoder**: Try decoding a German vehicle VIN
3. **Check Browser Console**: No CORS errors
4. **Test Features**: Image search, part identification

**Status**: [ ] Completed

---

## Verification Checklist

- [ ] Backend health endpoint responds: `http://207.180.249.87/api/health`
- [ ] Frontend loads on Vercel URL
- [ ] VIN decoder works
- [ ] Image search works
- [ ] Part identification works
- [ ] No CORS errors in browser console
- [ ] PWA installable on mobile device

---

## Post-Deployment Monitoring

### Check Backend Status
```bash
ssh root@207.180.249.87
pm2 status
pm2 logs moto-lens-api
pm2 monit
```

### Update Backend Code
```bash
ssh kiwana@207.180.249.87
cd /home/kiwana/moto-lens
git pull origin main
cd backend
npm install --production
pm2 restart moto-lens-api
```

### Update Frontend
Just push to GitHub `main` branch - Vercel auto-deploys

---

## Troubleshooting

### CORS Errors
- Check `FRONTEND_URL` in backend `.env` includes your Vercel domain
- Restart backend: `pm2 restart moto-lens-api`
- Check exact URL format (no trailing slashes)

### Backend Not Responding
```bash
# Check PM2 status
pm2 status

# Check logs
pm2 logs moto-lens-api --lines 50

# Check if port is in use
netstat -tlnp | grep 3001

# Restart if needed
pm2 restart moto-lens-api
```

### Vercel Build Failures
- Check build logs in Vercel dashboard
- Ensure all dependencies are in `package.json`
- Verify `VITE_API_BASE_URL` is set correctly

---

## Quick Reference

| Service | URL |
|---------|-----|
| Frontend | https://moto-lens.vercel.app |
| Backend API | http://207.180.249.87/api |
| Health Check | http://207.180.249.87/api/health |

| Command | Purpose |
|---------|---------|
| `pm2 status` | Check backend status |
| `pm2 logs moto-lens-api` | View logs |
| `pm2 restart moto-lens-api` | Restart backend |
| `pm2 monit` | Real-time monitoring |
| `nginx -t && systemctl reload nginx` | Reload Nginx |

---

## Next Steps (Optional)

### Setup Custom Domain
1. Point domain DNS to VPS: `api.yourdomain.com` → `207.180.249.87`
2. Install SSL: `certbot --nginx -d api.yourdomain.com`
3. Update Vercel env: `VITE_API_BASE_URL=https://api.yourdomain.com/api`

### Add Monitoring
- Setup PM2 monitoring dashboard
- Configure error alerting
- Setup uptime monitoring (UptimeRobot, etc.)
