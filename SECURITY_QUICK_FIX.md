# 🔐 Quick Security Reference - MotoLens

## Current Status
⚠️ **Google Cloud service account key was exposed on GitHub**
- Google will automatically disable it
- You MUST generate a new one
- Your REST API keys are OK for now but should be rotated too

---

## Your Current Setup Analysis

| Item | Status | Action |
|------|--------|--------|
| **Service Account JSON** | ❌ EXPOSED | ❌ ROTATE (new key) |
| **GEMINI_API_KEY** | ⚠️ IN `.env` | ✅ OK (gitignored), but ROTATE it |
| **AUTODEV_API_KEY** | ⚠️ IN `.env` | ✅ OK (gitignored), but ROTATE it |
| **`.gitignore`** | ✅ Configured | ✅ Good - already ignores `.env` and `*.json` |

---

## Immediate Fix (Next 30 minutes)

### 1. Generate New Google Cloud Credentials

**Go to:** https://console.cloud.google.com/iam-admin/serviceaccounts

```
1. Select project: quick-heaven-427615-f4
2. Click: moto-lens-imagen@quick-heaven-427615-f4.iam.gserviceaccount.com
3. Keys tab → Delete key ID: f99eabce6f6a
4. Add Key → Create new key → JSON format
5. Save file somewhere safe (NOT in repo)
```

### 2. Generate New Gemini API Key

**Go to:** https://aistudio.google.com/api-keys

```
1. Click: Create API Key
2. Copy the new key
3. Paste into your .env file as GEMINI_API_KEY
```

### 3. Clean Up Your Machine

```bash
# Remove exposed credential file
rm /Users/kiwana/projects/moto-lens/backend/quick-heaven-427615-f4-f99eabce6f6a.json

# Verify git won't track it anymore
cd /Users/kiwana/projects/moto-lens
git status  # Should NOT show the JSON file
```

### 4. Update Your Git History (IMPORTANT!)

```bash
# Option A - Simple (if not shared): Just delete from git
git rm --cached backend/quick-heaven-427615-f4-f99eabce6f6a.json
git commit -m "Remove exposed service account key"
git push origin main

# Option B - Deep clean (if already in history):
# Use git-filter-repo to rewrite history
pip install git-filter-repo
cd /Users/kiwana/projects/moto-lens
git filter-repo --path backend/quick-heaven-427615-f4-f99eabce6f6a.json --invert-paths
git push origin main --force-with-lease
```

---

## For Deployment

### Vercel (Recommended)
```
1. Go to Project Settings → Environment Variables
2. Add:
   - GEMINI_API_KEY = (new key)
   - AUTODEV_API_KEY = (new key)
   - GOOGLE_CLOUD_PROJECT_ID = quick-heaven-427615-f4
3. Don't add GOOGLE_APPLICATION_CREDENTIALS (not needed for REST APIs)
4. Deploy
```

### Railway / Other
Same process - use platform's environment variable UI

---

## Why This Happened

Your `.env` and `quick-heaven-427615-f4-f99eabce6f6a.json` were both:
- ✅ In `.gitignore` (so they shouldn't be committed)
- ❌ But the JSON file WAS committed before `.gitignore` was added
- ❌ Once committed, it's in git history forever (unless rewritten)
- 🔍 Google detected it on GitHub and flagged it

---

## Going Forward

```bash
# ALWAYS:
✅ Keep .env gitignored (already set up)
✅ Keep *.json gitignored (already set up)
✅ Never reference local paths in code
✅ Use environment variables for secrets

# NEVER:
❌ git add .env
❌ git add *.json
❌ Hardcode credentials in code
❌ Share credentials via Slack/email
❌ Publish credentials to public repos
```

---

## Verify Your Setup is Secure

```bash
cd /Users/kiwana/projects/moto-lens

# Check: Is .env gitignored?
grep "^.env$" .gitignore  # Should return .env

# Check: Are *.json files gitignored?
grep "*.json" .gitignore  # Should return *.json

# Check: No secrets in git history (after cleanup)
git log --all --source -- backend/quick-heaven-427615-f4-f99eabce6f6a.json
# If nothing shows, ✅ it's been removed

# Check: No .env tracked
git ls-files | grep ".env"  # Should return nothing
```

---

## Cost Impact

- **Rotating credentials:** $0 (free)
- **Disabling old service account key:** Free
- **Gemini API cost:** Unchanged (same service)
- **Auto.dev API cost:** Unchanged (same service)

**Total cost of security fix: $0**

---

## Questions?

**Q: Should I tell anyone about the exposure?**
- A: Not necessary - Google detected and will disable automatically
- Optional: You could note it in your repo ("Fixed exposed credentials")

**Q: Will this break anything?**
- A: No, if you update the new credentials in `.env` and deployment settings

**Q: Are my other services affected?**
- A: Only Google Cloud services using that specific key
- No impact on Auto.dev, Gemini API, or anything else

**Q: What if I didn't rotate?**
- A: Google disables the key automatically (already happening)
- You must rotate to keep using Google Cloud services

---

**Status:** ⚠️ ACTION REQUIRED  
**Timeline:** Complete within 1 hour  
**Risk Level:** HIGH until rotated, then LOW
