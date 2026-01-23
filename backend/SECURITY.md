# 🔒 MotoLens Security Guide

## Critical: Exposed Credentials Incident

**Status:** ⚠️ ACTION REQUIRED

Your Google Cloud service account key was exposed on GitHub. Google will disable it. You must:

1. ✅ Generate a new service account key
2. ✅ Rotate all API keys
3. ✅ Never commit credentials to git again
4. ✅ Update your deployment with new credentials

---

## 📋 Credential Types & Security

### Type 1: REST API Keys (GEMINI_API_KEY) - ✅ OK in `.env`
- **What:** Public API key for Google Gemini text/chat APIs
- **Security:** Browser/server-side origin restrictions available
- **Storage:** `.env` file (gitignored)
- **Deployment:** Environment variables in hosting platform
- **Current Status:** ✅ Safe in backend `.env` (not exposed publicly)

### Type 2: Service Account Keys (JSON) - ⚠️ NEVER in Git
- **What:** Private credentials for Google Cloud services
- **Security:** Full project access if compromised
- **Storage:** Local disk ONLY, in secure key management
- **Deployment:** Injected at runtime via hosting platform
- **Current Status:** ❌ EXPOSED on GitHub - must rotate!

### Type 3: Auto.dev API Key (AUTODEV_API_KEY) - ⚠️ Keep Private
- **What:** Private API key for VIN decoding service
- **Security:** Could enable abuse/quota exploitation
- **Storage:** `.env` file (gitignored)
- **Deployment:** Environment variables in hosting platform

---

## 🛡️ Secure Setup - What to Do NOW

### Step 1: Generate New Service Account (if needed for image generation)

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select project: `quick-heaven-427615-f4`
3. Go to **IAM & Admin → Service Accounts**
4. Click on `moto-lens-imagen@quick-heaven-427615-f4.iam.gserviceaccount.com`
5. Go to **Keys** tab
6. **Delete the old key** (marked f99eabce6f6a)
7. Click **Add Key → Create new key**
8. Choose **JSON** format
9. Save it locally (NOT in your repo)

### Step 2: Update `.env` with New Credentials

Replace with your new values:
```bash
# Option A: If using Gemini API (REST - simpler, recommended for MVP)
GEMINI_API_KEY=your_new_api_key_from_aistudio.google.com

# Option B: If using service account (store JSON locally only)
GOOGLE_APPLICATION_CREDENTIALS=/Users/kiwana/your-new-key.json
```

**CRITICAL:** Never commit the JSON key file!

### Step 3: Verify `.gitignore` is Correct

Your `.gitignore` should have:
```
# Environment variables
.env
.env.local
.env.*.local

# Google Cloud credentials (NEVER commit!)
*.json
backend/*.json
```

### Step 4: Clean GitHub History

Since the key was exposed, remove it from git history:

```bash
# Option A: Force-push (if you haven't shared this branch)
git rm --cached backend/quick-heaven-427615-f4-f99eabce6f6a.json
git commit --amend -m "Remove exposed credentials"
git push origin main --force-with-lease

# Option B: Use git-filter-repo (safest, rewrites history)
pip install git-filter-repo
cd /Users/kiwana/projects/moto-lens
git filter-repo --path backend/quick-heaven-427615-f4-f99eabce6f6a.json --invert-paths
```

**Note:** Force-pushing rewrites history. Notify your team if others have cloned.

### Step 5: Update Hosting Platform Secrets

When deploying, set environment variables on your platform:

**For Vercel:**
- Go to Project Settings → Environment Variables
- Add: `GEMINI_API_KEY`, `AUTODEV_API_KEY`, `GOOGLE_CLOUD_PROJECT_ID`
- Never paste into code - let Vercel inject them

**For Railway/Render:**
- Project Settings → Environment
- Set same variables as above

---

## 📝 Development Workflow (Going Forward)

### 1. Create `.env` from template
```bash
cd backend
cp .env.example .env
# Edit .env with your actual keys
```

### 2. Your `.env` contains secrets (gitignored):
```dotenv
GEMINI_API_KEY=AIzaSy...
AUTODEV_API_KEY=sk_ad_...
GOOGLE_CLOUD_PROJECT_ID=...
```

### 3. Never commit `.env`:
```bash
# ❌ WRONG
git add .env
git commit -m "Add keys"

# ✅ RIGHT
# .env is already in .gitignore, just don't override it
git status  # Should NOT show .env as modified
```

### 4. Share secrets securely:
```bash
# ❌ WRONG
"Here's my .env file" (via email/Slack)

# ✅ RIGHT
"Ask me for the env vars" (person-to-person)
OR
Use 1Password/Vault for team sharing
```

---

## 🔐 Best Practices Summary

| Practice | Why | Status |
|----------|-----|--------|
| **Never commit `.env`** | Credentials in git = permanent breach | ✅ Implement |
| **Never commit `*.json`** | Service account keys = full access | ✅ Implement |
| **Use environment variables** | Different configs per environment | ✅ Implement |
| **Rotate exposed keys** | Immediately if leaked | ⚠️ DO NOW |
| **Use API key restrictions** | Limit scope in Google Cloud | 🔲 Consider |
| **Use short-lived tokens** | JWT/OAuth better than static keys | 🔲 Future |

---

## 🚀 For Production Deployment

### Option 1: Vercel (Recommended for Budget)
```bash
# Deploy frontend + backend functions
vercel deploy
# Set env vars in dashboard - Vercel injects at runtime
```

### Option 2: Railway
```bash
# Connect GitHub repo
# Set environment variables in UI
# Railway auto-deploys on git push
```

### Option 3: Self-hosted
```bash
# Use .env.production with secrets from secure store
# Never hardcode credentials in code
# Rotate keys regularly
```

---

## ✅ Immediate Action Checklist

- [ ] Generate new Google Cloud service account key
- [ ] Update `.env` with new credentials
- [ ] Delete old key from Google Cloud Console
- [ ] Remove JSON file from git history
- [ ] Verify `.gitignore` includes `*.json`
- [ ] Commit `.gitignore` changes
- [ ] Force-push (or rebase) to remove exposed keys
- [ ] Test locally with new credentials
- [ ] Update deployment platform environment variables
- [ ] Notify Google Cloud that breach is resolved (optional)

---

## 🆘 Questions?

**"Can I keep the JSON file locally?"**
- Yes, but:
  1. Add `/backend/*.json` to `.gitignore` (✅ Done)
  2. Never push it to GitHub
  3. Store in secure location on your machine
  4. For production, use platform secrets instead

**"Is GEMINI_API_KEY safe in `.env`?"**
- Yes, because:
  1. `.env` is gitignored (never pushed)
  2. It's a REST API key (not full project access)
  3. You can set API key restrictions in Google Cloud
  4. Environment variables are the standard practice

**"What if I already pushed?"**
- Git history contains the key forever
  1. Force-push to remove history
  2. Immediately rotate credentials
  3. Google will disable automatically anyway
  4. Update all deployments with new keys

**"Should I use a different approach?"**
- For MotoLens MVP, this is the right approach:
  - Simple: Just REST API keys
  - Secure: Keys never in git, injected at runtime
  - Scalable: Works same way in dev, staging, production
  - Cost-effective: No extra services needed

---

*Last Updated: January 24, 2026*
