# MotoLens Deployment Guide

This guide covers deploying MotoLens with:
- **Frontend**: Vercel (React/Vite PWA)
- **Backend**: VPS at `207.180.249.87` (Node.js/Express API)

---

## Project Structure

```
moto-lens/
├── frontend/          # React/Vite PWA (deployed to Vercel)
│   ├── src/
│   ├── public/
│   ├── vercel.json
│   └── package.json
├── backend/           # Node.js/Express API (deployed to VPS)
│   ├── src/
│   ├── ecosystem.config.cjs
│   └── package.json
├── deployment/        # Deployment scripts
│   ├── vps-setup.sh
│   ├── deploy-backend.sh
│   └── nginx.conf
└── package.json       # Root workspace scripts
```

---

## Part 1: Backend Deployment (VPS)

### Step 1: Initial VPS Setup

SSH into your VPS:

```bash
ssh root@207.180.249.87
```

Run the setup script (or execute commands manually):

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
```

### Step 2: Clone Repository

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

### Step 3: Configure Environment

```bash
# Create .env file from example
cp .env.production.example .env

# Edit with your actual API keys
nano .env
```

Required environment variables:

```env
PORT=3001
NODE_ENV=production
FRONTEND_URL=https://moto-lens.vercel.app,https://*.vercel.app

# Your API keys
AUTODEV_API_KEY=your_key
GEMINI_API_KEY=your_key
SERPAPI_KEY=your_key
```

### Step 4: Start Backend with PM2

```bash
# Create logs directory
mkdir -p logs

# Start application
pm2 start ecosystem.config.cjs --env production

# Save PM2 process list (auto-restart on reboot)
pm2 save
pm2 startup
```

### Step 5: Configure Nginx

```bash
# Copy nginx config
cp /home/kiwana/moto-lens/deployment/nginx.conf /etc/nginx/sites-available/moto-lens

# Enable site
ln -s /etc/nginx/sites-available/moto-lens /etc/nginx/sites-enabled/

# Remove default site (optional)
rm /etc/nginx/sites-enabled/default

# Test and reload
nginx -t
systemctl reload nginx
```

### Step 6: Test Backend

```bash
# Test locally
curl http://localhost:3001/api/health

# Test via Nginx
curl http://207.180.249.87/api/health
```

Expected response:
```json
{"status":"ok","message":"MotoLens API is running","timestamp":"..."}
```

---

## Part 2: Frontend Deployment (Vercel)

### Step 1: Push to GitHub

Ensure your code is pushed to GitHub:

```bash
git add .
git commit -m "Restructure for deployment"
git push origin main
```

### Step 2: Connect to Vercel

1. Go to [vercel.com](https://vercel.com) and sign in with GitHub
2. Click **"Add New Project"**
3. Select your repository: `kiwanacollins/moto-lens`
4. Configure the project:
   - **Framework Preset**: Vite
   - **Root Directory**: `frontend`
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`

### Step 3: Configure Environment Variables

In Vercel Dashboard → Project Settings → Environment Variables:

| Name | Value |
|------|-------|
| `VITE_API_BASE_URL` | `http://207.180.249.87/api` |

> **Note**: Once you have a domain with SSL, update to `https://api.yourdomain.com/api`

### Step 4: Deploy

Click **"Deploy"** - Vercel will automatically build and deploy your frontend.

Your app will be available at:
- `https://moto-lens.vercel.app` (or your custom domain)

---

## Part 3: Post-Deployment

### Update CORS (Important!)

After you get your Vercel URL, update the backend `.env`:

```bash
ssh root@207.180.249.87
nano /var/www/moto-lens/backend/.env
```

Update `FRONTEND_URL`:

```env
FRONTEND_URL=https://moto-lens.vercel.app,https://moto-lens-*.vercel.app,http://localhost:5173
```

Restart the backend:

```bash
cd /var/www/moto-lens/backend
pm2 restart moto-lens-api
```

### Setup Custom Domain (Optional)

#### For Backend (API subdomain):

1. Add DNS A record: `api.yourdomain.com` → `207.180.249.87`
2. Install Certbot for SSL:

```bash
apt install -y certbot python3-certbot-nginx
certbot --nginx -d api.yourdomain.com
```

3. Update frontend env in Vercel:
   - `VITE_API_BASE_URL` = `https://api.yourdomain.com/api`

#### For Frontend:

1. In Vercel Dashboard → Domains → Add your domain
2. Follow DNS configuration instructions

---

## Maintenance Commands

### Backend (VPS)

```bash
# SSH into VPS
ssh root@207.180.249.87

# View logs
pm2 logs moto-lens-api

# Monitor resources
pm2 monit

# Restart application
pm2 restart moto-lens-api

# Update application
cd /home/kiwana/moto-lens
git pull origin main
cd backend
npm install --production
pm2 restart moto-lens-api

# Check status
pm2 status
```

### Frontend (Vercel)

- Push to `main` branch triggers automatic deployment
- Manual redeploy from Vercel Dashboard

---

## Troubleshooting

### CORS Errors

If you see CORS errors in browser console:

1. Check `FRONTEND_URL` in backend `.env` includes your Vercel domain
2. Restart backend: `pm2 restart moto-lens-api`
3. Check browser Network tab for actual error details

### Backend Not Responding

```bash
# Check if PM2 process is running
pm2 status

# Check logs for errors
pm2 logs moto-lens-api --lines 50

# Check if port 3001 is in use
netstat -tlnp | grep 3001

# Check Nginx status
systemctl status nginx
nginx -t
```

### Build Failures on Vercel

1. Check build logs in Vercel Dashboard
2. Ensure `frontend/package.json` has correct build script
3. Verify all dependencies are listed

---

## Quick Reference

| Service | URL |
|---------|-----|
| Frontend (Vercel) | `https://moto-lens.vercel.app` |
| Backend API | `http://207.180.249.87/api` |
| Health Check | `http://207.180.249.87/api/health` |

| Command | Purpose |
|---------|---------|
| `pm2 status` | Check backend status |
| `pm2 logs moto-lens-api` | View backend logs |
| `pm2 restart moto-lens-api` | Restart backend |
| `nginx -t && systemctl reload nginx` | Reload Nginx |
