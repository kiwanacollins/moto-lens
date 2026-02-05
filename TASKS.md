# 📋 MOTO LENS - Development Tasks

1HGCM82633A123456 <!-- Test VIN: 2003 Honda Accord -->
<!-- Invalid VIN example: WVWZZZCDZMW072001 (shows validation warnings) -->

## Project Overview
Building a **Flutter mobile application** for German vehicle VIN decoding and interactive part identification.

**Focus:** Mobile-first approach using Flutter  
**Budget:** Under $1,000  
**Timeline:** MVP in 4-6 weeks  
**Target Users:** 1-2 daily users (mechanics)

**Note:** PWA (React web app) development is **DEPRIORITIZED**. Focus is exclusively on Flutter mobile app with production backend.

---

## 🚀 **PRIORITY: FLUTTER MOBILE APP DEVELOPMENT**

**Active Development Phases:**
- ✅ Phase 12: Flutter Mobile Authentication UI Setup
- ✅ Phase 13: Flutter Authentication Screens
- 🔄 Phase 14: Backend Production Authentication System
- ⏳ Phase 15: Security & Production Features
- ⏳ Phase 16: Flutter Mobile Vehicle Features (VIN, Parts, 360° Viewer)
- ⏳ Phase 17: Integration Testing & Deployment

**Deprioritized (React PWA):**
- Phase 1-2: PWA Setup & Basic Auth → **SKIP** (Focus on mobile)
- Phase 4-8: PWA Frontend Features → **SKIP** (Focus on mobile)
- Phase 16 (PWA Migration section) → **SKIP** (Focus on mobile)

---

## 🎯 Phase 3: Backend API Setup (SHARED - Required for Mobile)

### 1.1 Initialize Project Structure
- [x] Create Vite + React + TypeScript project
- [x] Configure Mantine UI
  - [x] Install @mantine/core, @mantine/hooks
  - [x] Set up custom theme with brand colors:
    - [x] Carbon Black (primary background)
    - [x] Gunmetal Gray (secondary elements)
    - [x] Electric Blue (accents/CTAs)
  - [x] Configure mobile-first responsive breakpoints
- [x] Install custom fonts
  - [x] Inter (primary font) - Google Fonts or local
  - [x] JetBrains Mono (VINs/technical data) - Google Fonts or local
- [x] Install and configure vite-plugin-pwa
  - [x] Set up manifest.json
  - [x] Configure service worker for shell caching
  - [x] Add app icons (512x512, 192x192)
- [x] Set up project folder structure:
  ```
  src/
  ├── components/
  │   ├── auth/
  │   ├── vehicle/
  │   └── parts/
  ├── pages/
  │   ├── LoginPage.tsx
  │   ├── VinInputPage.tsx
  │   └── VehicleViewPage.tsx
  ├── services/
  ├── hooks/
  ├── types/
  ├── utils/
  ├── contexts/
  │   └── AuthContext.tsx
  └── styles/
      └── theme.ts
  ```

### 1.2 Environment Configuration
- [x] Create `.env` file structure
- [x] Set up environment variables:
  - [x] `VITE_API_BASE_URL`
  - [x] `VITE_AUTODEV_API_KEY`
  - [x] `VITE_GEMINI_API_KEY`
- [x] Add `.env.example` template
- [x] Update `.gitignore` for secrets

### 1.3 Development Tools
- [x] Configure ESLint for React + TypeScript
- [x] Set up Prettier
- [x] Add basic npm scripts (dev, build, preview)
- [x] Test PWA installability in Chrome DevTools

### 1.4 Design System Implementation
- [x] Create theme configuration file (`src/styles/theme.ts`)
- [x] Define color palette:
  ```typescript
  colors: {
    electricBlue: '#0ea5e9',  // sky-500 - Primary
    carbonBlack: '#0a0a0a',   // zinc-900 - Main text
    gunmetalGray: '#52525b',  // zinc-600 - Secondary text
    // + full zinc scale + semantic colors
  }
  ```
- [x] Configure Mantine theme with brand colors
- [x] Set up font loading (Inter + JetBrains Mono)
- [x] Create reusable style constants
- [x] Test colors in different lighting conditions

**Estimated Time:** 3-4 hours

---

## 🎯 Phase 2: Authentication & Routing

### 2.1 Dummy Authentication System
- [x] Create `AuthContext.tsx` with React Context
- [x] Implement dummy auth logic:
  - [x] Hardcoded credentials (admin/admin)
  - [x] Login function
  - [x] Logout function
  - [x] isAuthenticated state
- [x] Store auth state in localStorage
- [x] Create `useAuth` custom hook

### 2.2 Login Page
- [x] Create `LoginPage.tsx` component
- [x] Design mobile-first login form:
  - [x] Username input (Mantine TextInput)
  - [x] Password input (Mantine PasswordInput)
  - [x] Login button (Electric Blue, large tap target)
  - [x] Error message display
- [x] Apply brand styling:
  - [x] Carbon Black background
  - [x] Gunmetal Gray input fields
  - [x] Electric Blue accents
  - [x] Inter font for labels
  - [x] JetBrains Mono for input (optional)
- [x] Implement validation
- [x] Add smooth transitions
- [x] Test on mobile devices

### 2.3 Protected Routes
- [x] Install react-router-dom
- [x] Set up routing structure:
  - [x] `/login` - LoginPage
  - [x] `/` - VinInputPage (protected)
  - [x] `/vehicle/:vin` - VehicleViewPage (protected)
- [x] Create `ProtectedRoute` component
- [x] Implement route guards
- [x] Redirect to login if not authenticated
- [x] Redirect to home if already authenticated

**Estimated Time:** 2-3 hours

---

## 🎯 Phase 3: Backend API Setup

### 2.1 Node.js Backend Initialization
- [x] Create `/backend` directory
- [x] Initialize Node.js project (`npm init`)
- [x] Install dependencies:
  - [x] express
  - [x] cors
  - [x] dotenv
  - [x] axios (for external API calls)
- [x] Set up basic Express server
- [x] Configure CORS for frontend origin
- [x] Create environment config for backend

### 2.2 Auto.dev API Integration
- [x] Sign up for Auto.dev API account (1,000 free calls/month)
- [x] Test Auto.dev API with sample VINs
- [x] Create `/api/vin/decode` endpoint
- [x] Implement VIN validation (17 characters)
- [x] Parse Auto.dev response into clean format:
  ```typescript
  interface VehicleData {
    make: string;
    model: string;
    year: number;
    trim?: string;
    engine: string;
    bodyType: string;
    manufacturer: string;
  }
  ```
- [x] Add error handling for invalid VINs
- [x] Test with German vehicle VINs (BMW, Audi, Mercedes, VW, Porsche)

### 2.3 Web Image Search API Integration (UPDATED)
- [x] Sign up for SerpApi account (1,000 free searches/month)
- [ ] Get Google Custom Search Engine API key (100/day free)
- [ ] Get Microsoft Bing Image Search API key (1,000/month free)
- [x] Test image search APIs with German vehicle queries
- [x] Create `/api/vehicle/images` endpoint using web search
- [x] Create `/api/parts/images` endpoint for spare parts
- [x] Implement image deduplication and quality filtering
- [x] Add caching mechanism for search results
- [x] Compare costs vs Gemini (should be 50-100x cheaper)

### 2.4 AI Parts Information Endpoints
- [x] Create `/api/vehicle/summary` endpoint
  - [x] Use Vehicle Summary Prompt
  - [x] Return 5 bullet points
- [x] Create `/api/parts/identify` endpoint
  - [x] Use Part Identification Prompt
  - [x] Return structured part data
- [x] Create `/api/parts/spare-parts` endpoint
  - [x] Use Spare Parts Summary Prompt
  - [x] Return max 5 items
- [x] Implement system prompt for all Gemini calls
- [x] Test output quality (should NOT sound AI-generated)

**Estimated Time:** 4-6 hours

---

## 🎯 Phase 4: Frontend - VIN Input & Vehicle Display

### 4.1 VIN Input Page
- [x] Create `VinInputPage` component
- [x] Design mobile-first layout with brand styling:
  - [x] Light mode background (zinc-50)
  - [x] White card container
  - [x] Electric Blue accents
- [x] Add Mantine TextInput for VIN
  - [x] Style with JetBrains Mono font
  - [x] 17-character validation
  - [x] Uppercase transformation
  - [x] Clear visual feedback
- [x] Add submit button (Electric Blue, large, glove-friendly)
- [x] Implement loading state with brand colors
- [x] Handle API errors gracefully
- [x] Add sample VIN button for testing
- [x] Add logout button in header

### 4.2 Vehicle Service Layer
- [x] Create `vehicleService.ts`
- [x] Implement `decodeVIN(vin: string)` function
- [x] Implement `getVehicleImages(vehicleData)` function
- [x] Implement `getVehicleSummary(vehicleData)` function
- [x] Add TypeScript interfaces for all responses
- [x] Add error handling and retries

### 4.3 Vehicle Display Page
- [x] Create `VehicleViewPage` component
- [x] Display vehicle metadata with brand styling:
  - [x] Make, Model, Year (Inter font, large)
  - [x] Engine, Body Type (Inter font, medium)
  - [x] Trim (if available)
  - [x] VIN display (JetBrains Mono, Electric Blue)
- [x] Add AI-generated vehicle summary (5 bullets)
- [x] Style with brand colors:
  - [x] Carbon Black background
  - [x] Gunmetal Gray cards
  - [x] Electric Blue highlights
- [x] Add back button to re-enter VIN
- [x] Add logout option
- [x] Implement smooth page transitions

**Estimated Time:** 3-4 hours

---

## 🎯 Phase 5: 360° Car Viewer Implementation

### 4.1 Install and Configure react-360-view
- [x] Install `react-360-view` package
- [x] Test with sample images
- [x] Configure for mobile touch/swipe
- [x] Set up drag sensitivity
- [x] Add loading spinner while images load

### 4.2 Integrate Web Image Search (UPDATED - No More AI Generation)
- [x] Load 8 angle images from backend
- [x] Display in 360° viewer
- [x] Add image preloading
- [x] Replace Gemini with SerpApi/Bing web image search
- [x] Implement WebImageSearchService class
- [ ] Add Google Custom Search Engine as backup
- [x] Create parts image search endpoint
- [x] Test with German vehicles (BMW, Audi, VW, Mercedes, Porsche)
- [x] Update frontend to handle web search results
- [x] Remove AI generation code completely

### 4.3 Viewer UI Polish
- [x] Add rotation instructions (swipe hint) - Electric Blue text
- [x] Remove angle indicator text (front, rear, left, etc.)
- [x] Smooth loading transitions with brand styling
- [x] Test performance on mid-range phones
- [ ] Add pinch-to-zoom (optional)

**Estimated Time:** 3-4 hours

---

## 🎯 Phase 6: Parts Interaction System

### 5.1 SVG Hotspot System (Diagram-Style Arrows)
- [x] Research SVG overlay technique
- [x] Create `PartsOverlay` component with professional diagram styling
- [x] Define hotspot data structure:
  ```typescript
  interface Hotspot {
    id: string;
    partName: string;
    angle: string;
    coordinates: { x: number; y: number };
    radius: number;
  }
  ```
- [x] Implement diagram-style hotspot rendering:
  - [x] Red dots marking part locations on vehicle
  - [x] Red connecting lines from parts to labels
  - [x] White label boxes positioned outside vehicle boundary
  - [x] Smart label positioning (left/right based on part location)
  - [x] Toggle button to show/hide entire overlay
- [x] Add tap/click detection on dots and labels
- [x] Visual feedback: Electric Blue highlights, pulse animations
- [x] Persistent state across angle changes (no reset on rotation)
- [x] Mobile-optimized: 44px+ tap targets, glove-friendly
- [x] Professional styling: No AI slop patterns, clean diagram aesthetic

### 5.2 Part Detail Modal (Arrow System Integration)
- [x] Create `PartDetailModal` component matching arrow aesthetic
- [x] Style with brand colors and diagram consistency:
  - [x] Carbon Black background with white content area
  - [x] Electric Blue header matching hotspot accent color
  - [x] Inter font for descriptions, JetBrains Mono for part numbers
  - [x] Red accent line connecting to clicked part (visual continuity)
  - [x] Clean, technical diagram styling (not generic modal)
- [x] Fetch part info from backend `/api/parts/identify` endpoint
- [x] Display with professional mechanic focus:
  - [x] Part name (large, clear heading)
  - [x] Function description (technical but accessible)
  - [x] Common failure symptoms (practical mechanic insights)
  - [x] Related spare parts with part numbers (max 5)
  - [x] Visual part location reference (angle + coordinates)
- [x] Professional interactions:
  - [x] Large close button with Electric Blue styling
  - [x] Smooth slide-up animations (mobile-first)
  - [x] One-hand operation optimized for garage use
  - [x] Tap outside to close, swipe down gesture support

### 5.3 Hotspot Data & Spare Parts Integration
- [x] Create comprehensive JSON file with 29 common parts:
  - [x] Engine components: Hood, radiator grille, headlights
  - [x] Body panels: Bumpers, fenders, doors, quarter panels
  - [x] Wheels & suspension: Tires, wheels, rocker panels
  - [x] Electrical: Tail lights, mirrors, windows
  - [x] Mapped across 8 viewing angles (front, rear, left, right, etc.)
- [x] Expand part data for spare parts workflow:
  - [x] Add OEM part numbers to hotspots.json
  - [x] Include common aftermarket alternatives
  - [x] Add failure frequency data for priority ranking
  - [x] Link to supplier catalogs (BMW, Audi, Mercedes, VW, Porsche)
- [x] Create spare parts display components using arrow aesthetic:
  - [x] `SparePartsList` with red dot indicators
  - [x] `PartAvailability` status with connecting lines
  - [x] `PriceComparison` maintaining diagram styling
  - [x] `InstallationGuide` with step-by-step arrows
- [x] Test tap accuracy on mobile

**Estimated Time:** 4-5 hours

---

## 🎯 Phase 7: Spare Parts Components (Arrow/Diagram Aesthetic)

### 6.1 Spare Parts List Display
- [x] Create `SparePartsList` component with arrow styling
- [x] Design consistent with vehicle hotspot system:
  - [x] Red dots for part indicators
  - [x] Connecting lines to part information
  - [x] White/light backgrounds for readability
  - [x] Electric Blue accents for actions
  - [x] Professional technical diagram appearance
- [x] Display spare parts with mechanic-focused data:
  - [x] OEM part numbers (JetBrains Mono)
  - [x] Aftermarket alternatives with quality ratings
  - [x] Price comparison (OEM vs aftermarket)
  - [x] Availability status (in stock, 2-day delivery, etc.)
  - [x] Installation difficulty (easy, moderate, expert)
- [x] Integrate with existing hotspot data
- [x] Filter by vehicle system (engine, electrical, body, etc.)

### 6.2 Part Detail Pages with Arrow Continuity
- [x] Create detailed part pages maintaining visual consistency (via PartDetailModal + components)
- [x] Visual connection to vehicle hotspot system:
  - [x] Show part location on mini vehicle diagram (in PartDetailModal)
  - [x] Use same red dot + connecting line aesthetic
  - [x] Breadcrumb navigation with arrow indicators (integrated in components)
- [x] Comprehensive part information:
  - [x] Technical specifications (in PartDetailModal)
  - [x] Compatible vehicle years/models (via enhanced hotspot data)
  - [x] Installation guides with step arrows (InstallationGuide component)
  - [x] Common failure modes (in hotspot failure frequency data)
  - [x] Maintenance intervals (via avgLifespanYears in data)
- [x] Shopping integration:
  - [x] Multiple supplier pricing (PriceComparison component)
  - [x] Quality ratings and reviews (in aftermarket alternatives)
  - [x] Shipping options and times (PartAvailability component)
  - [x] Return policies (integrated in supplier data)

### 6.3 Visual Consistency System
- [x] Create design tokens for arrow/diagram components:
  - [x] Red dot specifications (#ef4444, sizes, shadows)
  - [x] Connecting line styles (width, color, animations)
  - [x] Label box styling (padding, borders, backgrounds)
  - [x] Electric Blue interaction states
- [x] Standardize animation patterns:
  - [x] Pulse animations for active elements
  - [x] Smooth line drawing animations (via Mantine transitions)
  - [x] Hover/tap feedback consistency
- [x] Mobile optimization for garage use:
  - [x] High contrast for bright environments
  - [x] Large tap targets (44px+) throughout
  - [x] One-handed navigation patterns
  - [x] Glove-friendly interface elements

**Estimated Time:** 3-4 hours

---

## 🎯 Phase 8: PWA Features & Polish

### 7.1 PWA Manifest & Icons
- [ ] Create app icons (512x512, 192x192, maskable) with brand colors
  - [ ] Carbon Black background
  - [ ] Electric Blue logo/accent
- [ ] Configure `manifest.json`:
  - [ ] App name: "MOTO LENS"
  - [ ] Short name: "MotoLens"
  - [ ] Theme color: Electric Blue (#00D9FF)
  - [ ] Background color: Carbon Black
  - [ ] Display: "standalone"
  - [ ] Orientation: "portrait"
- [ ] Test install prompt on Android/iOS

### 7.2 Service Worker Configuration
- [ ] Configure workbox via vite-plugin-pwa
- [ ] Cache app shell (HTML, CSS, JS)
- [ ] Add offline fallback page
- [ ] Test offline behavior
- [ ] Add update notification when new version available

### 7.3 Mobile Optimizations
- [ ] Test on real devices (Android + iOS)
- [ ] Ensure tap targets are ≥44px
- [ ] Test with gloves (if possible)
- [ ] Optimize for slow 3G connections
- [ ] Add loading skeletons for better perceived performance
- [ ] Test in bright sunlight (contrast check)

### 7.4 Brand Consistency Check
- [ ] Review all pages for consistent color usage
- [ ] Verify Inter font is used for all UI text
- [ ] Verify JetBrains Mono for VINs and technical data
- [ ] Check Electric Blue accents are prominent but not overwhelming
- [ ] Test contrast ratios for accessibility
- [ ] Ensure Carbon Black/Gunmetal Gray backgrounds throughout

**Estimated Time:** 3-4 hours

---

## 🎯 Phase 9: Testing & Refinement

### 8.1 Functionality Testing
- [ ] Test full login → VIN → parts flow
- [ ] Test dummy authentication (admin/admin)
- [ ] Test logout functionality
- [ ] Test with multiple German vehicle VINs:
  - [ ] BMW (e.g., WBA series)
  - [ ] Audi (e.g., WAU series)
  - [ ] Mercedes-Benz (e.g., WDD series)
  - [ ] Volkswagen (e.g., WVW series)
  - [ ] Porsche (e.g., WP0 series)
- [ ] Test error handling (invalid VIN, API failures, wrong login)
- [ ] Test offline behavior
- [ ] Test PWA install and launch

### 8.2 Performance Testing
- [ ] Measure page load times
- [ ] Check image loading performance
- [ ] Test on 3G connection
- [ ] Optimize bundle size if needed
- [ ] Run Lighthouse audit (PWA, Performance, Accessibility)

### 8.3 UX Testing
- [ ] Test one-handed usage
- [ ] Verify tap target sizes (≥44px)
- [ ] Check text readability with brand colors
- [ ] Test brand color visibility in different lighting
- [ ] Verify Electric Blue accents are visible in sunlight
- [ ] Test login flow smoothness
- [ ] Test with actual mechanic if possible
- [ ] Gather feedback and iterate

### 8.4 Bug Fixes & Polish
- [ ] Fix any identified bugs
- [ ] Smooth out animations
- [ ] Add loading states where missing
- [ ] Improve error messages
- [ ] Final design polish

**Estimated Time:** 3-4 hours

---

## 🎯 Phase 10: Deployment

### 9.1 Backend Deployment
- [ ] Choose hosting platform:
  - Option A: Vercel Serverless Functions (recommended for budget)
  - Option B: Railway
  - Option C: Render free tier
- [ ] Set up environment variables in hosting platform
- [ ] Deploy backend
- [ ] Test deployed endpoints
- [ ] Set up domain/subdomain if needed

### 9.2 Frontend Deployment
- [ ] Build production bundle (`npm run build`)
- [ ] Test production build locally
- [ ] Deploy to:
  - Option A: Vercel (recommended)
  - Option B: Netlify
  - Option C: Cloudflare Pages
- [ ] Configure custom domain (optional)
- [ ] Test PWA install from live URL
- [ ] Verify HTTPS is working

### 9.3 API Keys & Monitoring
- [ ] Verify all API keys are working in production
- [ ] Set up basic usage monitoring:
  - [ ] VINLink API usage
  - [ ] Gemini API usage
- [ ] Set up budget alerts if platform supports it
- [ ] Document API costs per request

### 9.4 Documentation
- [ ] Update README.md with:
  - [ ] Project description
  - [ ] Setup instructions
  - [ ] Environment variables needed
  - [ ] Deployment steps
- [ ] Create user guide (optional)
- [ ] Document API endpoints (for future reference)

**Estimated Time:** 2-3 hours

---

## 🎯 Phase 11: Post-Launch (Optional)

### 10.1 Monitoring & Feedback
- [ ] Monitor API costs daily
- [ ] Gather user feedback
- [ ] Track any errors/crashes
- [ ] Monitor performance metrics

### 10.2 Quick Wins
- [ ] Add VIN history (localStorage)
- [ ] Cache previously decoded VINs
- [ ] Add more hotspot parts
- [ ] Improve AI prompts based on output quality

---

## 📊 Time Estimate Summary

| Phase | Task | Estimated Time |
|-------|------|----------------|
| 1 | Project Setup & Design System | 3-4 hours |
| 2 | Authentication & Routing | 2-3 hours |
| 3 | Backend API | 4-6 hours |
| 4 | VIN Input & Display | 3-4 hours |
| 5 | 360° Viewer | 3-4 hours |
| 6 | Parts Interaction (Arrow System) | 4-5 hours |
| 7 | Spare Parts Components (Arrow Aesthetic) | 3-4 hours |
| 8 | PWA Features | 3-4 hours |
| 9 | Testing | 3-4 hours |
| 10 | Deployment | 2-3 hours |
| **Total** | | **30-41 hours** |

**Realistic Timeline:** 4-5 working days for a focused developer

---

## 🚨 Critical Path Items

These must work for MVP to be viable:

1. ✅ Dummy login (admin/admin) works and persists session
2. ✅ Brand design system (Carbon Black, Gunmetal Gray, Electric Blue) consistently applied
3. ✅ Auto.dev API successfully decodes German vehicle VINs
4. ✅ Gemini generates professional-looking (non-AI) responses
5. ✅ 360° viewer works smoothly on mobile
6. ✅ PWA installs correctly on Android/iOS with brand colors
7. ✅ Total costs stay under $1,000

---

## 💰 Budget Tracking

| Service | Cost Model | Estimated MVP Cost |
|---------|------------|-------------------|
| Auto.dev API | 1,000 free calls/month, then $0.004/call | $0 (under free tier) |
| SerpApi (Images) | 1,000 free searches/month, then $50/5k | $0-50 (much cheaper than Gemini) |
| Bing Image Search | 1,000 free/month, then $2/1k | $0-20 (excellent backup) |
| Google Custom Search | 100/day free, then $5/1k | $0-15 (occasional use) |
| Hosting (Backend) | Free tier / $5-10/mo | $0-20 |
| Hosting (Frontend) | Free tier | $0 |
| Domain (optional) | $10-15/year | $0-15 |
| **Total** | | **$0-120** (vs previous $100-335) |

**Remaining budget for scaling:** $880-1000 (much better!)

---

## 🔧 Technical Risks & Mitigations (Mobile-Focused)

| Risk | Mitigation | Status |
|------|-----------|---------|
| Flutter secure storage compatibility issues | Test on multiple Android versions; fallback to encrypted SharedPreferences | ⏳ Pending |
| Backend API performance under load | Implement caching; rate limiting; database indexing | ✅ Rate limiting done |
| Auto.dev limited German vehicle coverage | Test thoroughly with German VINs; 1,000 free calls for testing | ✅ Tested |
| Image search returns low quality results | Use multiple APIs (SerpApi + Bing + Google); filter by size/quality | ✅ Implemented |
| 360° viewer performance on low-end Android | Optimize image sizes; progressive loading; use thumbnails | ⏳ Pending |
| JWT token security vulnerabilities | Use strong secrets (32+ chars); short expiry; token rotation; blacklisting | ✅ Implemented |
| Email deliverability issues | Use reputable SMTP (Gmail); implement retry logic; track delivery status | ✅ Implemented |
| Google Play Store rejection | Follow Android guidelines; test thoroughly; proper permissions | ⏳ Pending |
| Database performance with growing users | Prisma query optimization; connection pooling; proper indexing | ✅ Schema optimized |
| Offline sync conflicts | Implement conflict resolution; queue API calls; timestamp-based merging | ⏳ Pending |
| Brand colors not visible in bright garage | Test in real conditions; adjust Electric Blue brightness if needed | ⏳ Pending |
| Camera permission denial for VIN scanning | Provide manual input fallback; clear permission rationale | ⏳ Pending |
| Network connectivity issues in garages | Robust offline mode; clear connectivity indicators; offline caching | ⏳ Pending |

**Removed PWA Risks:**
- ❌ PWA install issues on iOS - Not applicable
- ❌ React/Vite build size - Not applicable
- ❌ Service worker caching - Not applicable

---

## 📝 Notes & Decisions

**Mobile-First Approach:**
- ✅ Flutter mobile app is primary focus
- ❌ React PWA deprioritized for future work
- ✅ Production backend with PostgreSQL + Prisma
- ✅ Production authentication system (JWT)
- ✅ Comprehensive security features (Helmet, rate limiting, CSRF, XSS, SQL injection)

**Design System:**
- ✅ Brand colors: Carbon Black, Gunmetal Gray, Electric Blue
- ✅ Fonts: Inter (UI), JetBrains Mono (VINs/technical data)
- ✅ Mobile-optimized: 44px+ tap targets, glove-friendly
- ✅ High contrast for garage conditions

**Backend Infrastructure:**
- ✅ PostgreSQL database with 10 tables
- ✅ Prisma ORM for type-safe database access
- ✅ JWT authentication with token rotation
- ✅ bcrypt password hashing (12 rounds)
- ✅ Email service with Nodemailer (Gmail SMTP, 500/day free)
- ✅ Rate limiting on all authentication endpoints
- ✅ Security logging and audit trails

**Third-Party APIs:**
- ✅ Auto.dev for VIN decoding (German vehicles focus)
- ✅ SerpApi for vehicle image search (web search, not AI generation)
- ✅ Google Gemini for AI-generated parts information
- ✅ All using free tiers for MVP (1,000 calls/month each)

**Deployment Strategy:**
- Android: Google Play Store ($25 one-time)
- iOS: Deprioritized (requires $99/year Apple Developer account)
- Backend: Railway, Render, or AWS (est. $10-30/month)
- Database: Managed PostgreSQL (est. $25-100/month)
- Total monthly: $35-130 (well under $1,000 budget)

**Security Measures:**
- ✅ JWT access tokens (15 min) + refresh tokens (7 days)
- ✅ Token blacklisting on logout
- ✅ Account lockout after 5 failed login attempts
- ✅ Password history (prevent reuse of last 5)
- ✅ Email verification required
- ✅ Device tracking for suspicious login detection
- ✅ Helmet.js security headers (CSP, HSTS, X-Frame-Options)
- ✅ Rate limiting: global (100/15min), auth (10/15min), registration (3/hour)
- ✅ Input sanitization, XSS prevention, CSRF protection, SQL injection validation

**Future Considerations:**
- Add iOS support when budget allows
- Consider PWA for web access (React frontend already exists)
- Implement 2FA/TOTP for enhanced security
- Add subscription tiers and billing integration
- Expand to non-German vehicles
- Add social login (Google, Apple)

---

## ✅ Definition of Done (Mobile App MVP)

The mobile app MVP is complete when:

1. ✅ Backend API successfully decodes German vehicle VINs (Auto.dev)
2. ✅ Backend provides vehicle images via web search (SerpApi)
3. ✅ Backend generates professional parts information (Gemini AI)
4. ✅ Flutter app has production authentication system
5. ✅ Mechanic can register, verify email, and log in securely
6. ✅ Password reset flow works end-to-end
7. ✅ JWT token management with automatic refresh
8. ✅ Advanced security features (rate limiting, CSRF, XSS, SQL injection protection)
9. [ ] Flutter app can scan/input VIN and display vehicle information
10. [ ] 360° vehicle viewer works smoothly on Android
11. [ ] Interactive parts hotspot system with 29 common parts
12. [ ] Spare parts information displays correctly
13. [ ] App works in offline mode with proper sync
14. [ ] MotoLens brand design (Electric Blue, Carbon Black, Gunmetal Gray) consistent
15. [ ] Fonts (Inter & JetBrains Mono) properly applied
16. [ ] App works in typical garage conditions (high contrast, one-handed, glove-friendly)
17. [ ] Published to Google Play Store (internal testing track minimum)
18. [ ] Total monthly spend under $130 (budget compliant)

**Current Progress: 8/18 criteria complete (44%)**

**PWA (Deprioritized):**
- ❌ PWA installation not required for MVP
- ❌ React web frontend not required for MVP
- ❌ Cross-platform sync not required for MVP

---

## 🎯 Phase 12: Flutter Mobile Authentication UI (PRIORITY - HARDEST PART) ✅ **MAJOR PROGRESS**

> **Status**: Core authentication UI completed - login, registration (simplified 2-step), password reset screens with professional MotoLens branding

### 12.1 Flutter Project Setup & Dependencies
- [x] Initialize Flutter project structure in `moto_lens_mobile/`
- [x] Add authentication dependencies to `pubspec.yaml`:
  - [x] `flutter_secure_storage: ^10.0.0` (secure token storage - upgraded)
  - [x] `http: ^1.1.0` (API calls)
  - [x] `provider: ^6.1.1` (state management)
  - [x] `shared_preferences: ^2.2.2` (user preferences)
  - [x] `form_builder_validators: ^11.3.0` (form validation - upgraded)
  - [x] `flutter_form_builder: ^10.3.0+1` (form widgets - upgraded)
- [x] Configure Android permissions in `android/app/src/main/AndroidManifest.xml`:
  - [x] Internet permission
  - [x] Network state permission
- [x] Configure iOS permissions in `ios/Runner/Info.plist`
- [x] Test dependency installation and basic app launch

### 12.2 Design System & Brand Implementation
- [x] Create `lib/styles/` directory structure:
  ```
  lib/styles/
  ├── app_colors.dart      # MotoLens brand colors
  ├── app_typography.dart  # Inter + JetBrains Mono
  ├── app_spacing.dart     # Consistent spacing
  └── app_theme.dart       # Complete theme
  ```
- [x] Implement MotoLens brand colors:
  - [x] Electric Blue: `#0ea5e9` (primary)
  - [x] Carbon Black: `#0a0a0a` (text/backgrounds)
  - [x] Gunmetal Gray: `#52525b` (secondary text)
  - [x] Zinc scale: 50, 100, 200, etc.
- [x] Configure custom fonts (Inter + JetBrains Mono):
  - [x] Create typography classes matching React PWA
  - [x] Font family constants and text styles
  - [x] Automotive-specific styles (VIN display, part numbers)
- [x] Create reusable UI components:
  - [x] `CustomButton` (Electric Blue primary, proper tap targets)
  - [x] `CustomTextField` (brand styling, high contrast)
  - [x] `LoadingSpinner` (Electric Blue accent)
  - [x] `ErrorMessage` (red semantic color)
  - [x] `BrandCard` (white background, subtle shadows)
- [x] Implement complete MotoLens theme system
- [x] Create design system demo page
- [x] Integrate theme with main app

### 12.3 Authentication Models & Data Classes
- [x] Create `lib/models/auth/` directory
- [x] Implement `User` model:
  ```dart
  class User {
    final String id;
    final String email;
    final String? username;
    final String firstName;
    final String lastName;
    final String? garageName;
    final UserRole role;
    final SubscriptionTier subscriptionTier;
    final bool emailVerified;
  }
  ```
- [x] Implement `AuthResponse` model for API responses
- [x] Implement `LoginRequest` and `RegisterRequest` models
- [x] Create `UserProfile` model for extended user data
- [x] Add JSON serialization/deserialization methods
- [x] Create validation methods for email, password, etc.
- [x] Add `copyWith` methods for immutable updates

### 12.4 Secure Storage Service
- [x] Create `lib/services/secure_storage_service.dart`
- [x] Implement secure token storage:
  ```dart
  class SecureStorageService {
    final FlutterSecureStorage _storage;
    
    Future<void> saveTokens(String accessToken, String refreshToken);
    Future<String?> getAccessToken();
    Future<String?> getRefreshToken();
    Future<void> deleteTokens();
    Future<bool> hasValidTokens();
  }
  ```
- [x] Add encryption for sensitive data on Android
- [x] Configure iOS Keychain settings
- [x] Implement token expiry checking
- [x] Add error handling for storage failures
- [x] Test storage persistence across app restarts

### 12.5 HTTP API Service Layer
- [x] Create `lib/services/api_service.dart`
- [x] Implement base HTTP client:
  ```dart
  class ApiService {
    final String baseUrl = 'https://api.motolens.com';
    
    Future<http.Response> get(String endpoint, {Map<String, String>? headers});
    Future<http.Response> post(String endpoint, {Map<String, dynamic>? body});
    Future<http.Response> put(String endpoint, {Map<String, dynamic>? body});
    Future<http.Response> delete(String endpoint);
  }
  ```
- [x] Add automatic JWT token attachment to headers
- [x] Implement automatic token refresh on 401 errors
- [x] Add request/response interceptors for logging
- [x] Add network error handling and user-friendly messages
- [x] Add timeout configuration (30 seconds)
- [x] Implement retry logic for failed requests

### 12.6 Authentication Service
- [x] Create `lib/services/auth_service.dart`
- [x] Implement core authentication methods:
  ```dart
  class AuthService {
    Future<AuthResponse> login(String email, String password);
    Future<AuthResponse> register(RegisterRequest request);
    Future<void> logout();
    Future<bool> refreshToken();
    Future<User?> getCurrentUser();
    Future<void> logoutFromAllDevices();

    // Password management
    Future<void> forgotPassword(String email);
    Future<bool> resetPassword(String token, String newPassword);
    Future<bool> changePassword(String currentPassword, String newPassword);

    // Email verification
    Future<void> verifyEmail(String token);
    Future<void> resendVerification();
  }
  ```
- [x] Add comprehensive error handling with custom exceptions
- [x] Implement device fingerprinting (model, OS version)
- [x] Add login attempt tracking and security measures
- [x] Test all methods with mock backend responses (34/35 tests passing)

**Estimated Time:** 6-8 hours

---

## 🎯 Phase 13: Flutter Authentication UI Screens

### 13.1 Splash Screen & Auto-Login
- [x] Create `lib/screens/auth/splash_screen.dart`
- [x] Design branded splash screen:
  - [x] MotoLens logo (Electric Blue on Carbon Black)
  - [x] Professional loading indicator
  - [x] Brand typography for tagline
- [x] Implement automatic authentication check:
  ```dart
  class SplashScreen extends StatefulWidget {
    @override
    _SplashScreenState createState() => _SplashScreenState();
  }

  class _SplashScreenState extends State<SplashScreen> {
    @override
    void initState() {
      super.initState();
      _checkAuthStatus();
    }

    Future<void> _checkAuthStatus() async {
      await Future.delayed(Duration(seconds: 2)); // Branding display

      final hasValidToken = await SecureStorageService().hasValidTokens();
      if (hasValidToken) {
        final user = await AuthService().getCurrentUser();
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/dashboard');
          return;
        }
      }
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
  ```
- [x] Add smooth transitions to next screen
- [x] Handle network connectivity issues gracefully
- [x] Add error handling for corrupt token data

### 13.2 Login Screen (Professional Design)
- [x] Create `lib/screens/auth/login_screen.dart`
- [x] Design mobile-first login form with MotoLens branding:
  - [x] Carbon Black background with white content cards
  - [x] MotoLens logo at top (appropriate size)
  - [x] Email field (professional styling, auto-focus)
  - [x] Password field (secure, show/hide toggle)
  - [x] Electric Blue login button (large, 48px+ height)
  - [x] Professional error messages (red semantic color)
  - [x] "Forgot Password?" link (Gunmetal Gray)
  - [x] "Create Account" navigation (Electric Blue accent)
- [x] Implement form validation:
  ```dart
  class LoginForm extends StatefulWidget {
    @override
    _LoginFormState createState() => _LoginFormState();
  }
  
  class _LoginFormState extends State<LoginForm> {
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    bool _isLoading = false;
    String? _error;
    
    Future<void> _handleLogin() async {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
        
        try {
          await context.read<AuthProvider>().login(
            _emailController.text.trim(),
            _passwordController.text,
          );
          Navigator.pushReplacementNamed(context, '/dashboard');
        } catch (e) {
          setState(() {
            _error = e.toString();
          });
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  ```
- [x] Add keyboard-friendly design (proper focus management)
- [x] Add "Remember Me" functionality (optional)
- [x] Implement smooth loading states with brand styling
- [x] Add accessibility labels for screen readers
- [x] Test with various email formats and edge cases

### 13.3 Registration Screen (Multi-Step)
- [x] Create `lib/screens/auth/register_screen.dart`
- [x] Design professional 2-step registration (simplified for mechanics only):
  
  **Step 1: Personal Information & Garage Details**
  - [x] Email field (with validation)
  - [x] First Name field
  - [x] Last Name field
  - [x] Username field (optional)
  - [x] Garage/Shop Name field (required for mechanics)
  - [x] Phone Number field (optional)
  - [x] Progress indicator (1/2)
  
  **Step 2: Password & Terms**
  - [x] Password field (strength indicator)
  - [x] Confirm password field
  - [x] Terms and conditions acceptance
  - [x] Marketing communications opt-in (optional)
  - [x] Progress indicator (2/2)
  
- [ ] Implement form state management:
  ```dart
  class RegistrationState {
    final String email;
    final String password;
    final String firstName;
    final String lastName;
    final String? phoneNumber;
    final String? garageName;
    final UserRole role;
    final int yearsExperience;
    final List<String> specializations;
    
    RegistrationState copyWith({...});
  }
  ```
- [x] Add real-time validation for each field
- [x] Implement password strength checking
- [x] Add email format validation with domain checking  
- [x] Create smooth step transitions (slide animations)
- [x] Add back button functionality without losing data
- [x] Test complete registration flow end-to-end

### 13.4 Authentication State Management
- [x] Create `lib/providers/auth_provider.dart`
- [x] Implement comprehensive auth state:
  ```dart
  class AuthProvider extends ChangeNotifier {
    User? _user;
    bool _isAuthenticated = false;
    bool _isLoading = false;
    String? _error;
    
    // Getters
    User? get user => _user;
    bool get isAuthenticated => _isAuthenticated;
    bool get isLoading => _isLoading;
    String? get error => _error;
    
    // Core methods
    Future<void> login(String email, String password);
    Future<void> register(RegisterRequest request);
    Future<void> logout();
    Future<void> logoutFromAllDevices();
    
    // Profile management
    Future<void> updateProfile(UserProfile profile);
    Future<void> changePassword(String current, String new);
    
    // Session management
    Future<void> refreshSession();
    void clearError();
    
    // Auto token refresh
    void startTokenRefreshTimer();
    void stopTokenRefreshTimer();
  }
  ```
- [x] Add automatic token refresh every 14 minutes
- [x] Implement logout on token expiry
- [x] Add session monitoring and cleanup
- [x] Handle network connectivity changes
- [x] Add comprehensive error state management

### 13.5 Password Management Screens
- [x] Create `lib/screens/auth/forgot_password_screen.dart`:
  - [x] Email input with validation
  - [x] Professional "Send Reset Link" button
  - [x] Success message with next steps
  - [x] Return to login navigation
  
- [x] Create `lib/screens/auth/reset_password_screen.dart`:
  - [x] New password field with strength indicator
  - [x] Confirm password field
  - [x] Professional submit button
  - [x] Success message and auto-navigation to login
  
- [x] Create `lib/screens/profile/change_password_screen.dart`:
  - [x] Current password field
  - [x] New password field (strength checking)
  - [x] Confirm new password field
  - [x] Professional save button
  - [x] Success feedback

**Estimated Time:** 8-10 hours ✅ **COMPLETED**

> ✅ **Phase 13 Authentication UI Complete**:
> - ✅ Login screen with professional MotoLens branding
> - ✅ Simplified 2-step registration (mechanics only)
> - ✅ Password reset request flow (forgot password)
> - ✅ Password reset screen with token-based reset, strength indicator, and auto-navigation
> - ⏳ Change password screen (authenticated users) - Pending
>
> All screens feature comprehensive form validation, real-time feedback, password strength indicators, and mobile-optimized design with Electric Blue branding.

---

## 🎯 Phase 14: Backend Production Authentication System

### 14.1 Database Setup & Schema ✅ **COMPLETED**
- [x] Install and configure PostgreSQL dependencies:
  - [x] `npm install prisma @prisma/client`
  - [x] `npm install jsonwebtoken bcryptjs`
  - [x] `npm install express-rate-limit helmet express-validator`
  - [x] `npm install nodemailer uuid`
- [x] Create `backend/prisma/schema.prisma` with 9 models:
  - [x] User model with authentication fields
  - [x] UserProfile model for extended data
  - [x] UserSession model for token tracking
  - [x] LoginHistory model for security auditing
  - [x] PasswordResetToken model
  - [x] EmailVerificationToken model
  - [x] VinScanHistory model
  - [x] ApiUsage model for tracking
  - [x] SecurityEvent model for logging
- [x] Run initial migration: `npx prisma migrate dev --name init`
- [x] Generate Prisma client: `npx prisma generate`
- [x] Set up database connection
- [x] Configure environment variables (JWT secrets, database URL)
- [x] Create documentation (DATABASE_SETUP.md, QUICK_START.md)

> ✅ **Complete**: Database operational with 10 tables, Prisma Client generated, JWT secrets configured

### 14.2 JWT Utilities & Security ✅ **COMPLETED**
- [x] Create `backend/src/utils/jwt.js`:
  - [x] `generateAccessToken(user)` - Generate 15-minute access tokens
  - [x] `generateRefreshToken(user)` - Generate 7-day refresh tokens
  - [x] `verifyAccessToken(token)` - Verify access tokens with blacklist check
  - [x] `verifyRefreshToken(token)` - Verify refresh tokens with blacklist check
  - [x] `blacklistToken(token, reason)` - Revoke tokens (logout/security)
  - [x] `isTokenBlacklisted(token)` - Check token blacklist status
  - [x] `rotateTokens(oldRefreshToken, user)` - Token rotation on refresh
  - [x] `generateTokenPair(user)` - Generate both tokens at once
  - [x] `extractTokenFromHeader(authHeader)` - Parse Bearer tokens
  - [x] `decodeToken(token)` - Decode without verification (debugging)
  - [x] `getTokenExpiration(token)` - Get token expiry date
  - [x] `isTokenExpired(token)` - Check if token is expired
- [x] Implement token blacklisting system using UserSession table
- [x] Add token rotation on refresh with old token revocation
- [x] Create secure token storage and extraction helpers
- [x] Add JWT middleware for protected routes (`src/middleware/auth.js`):
  - [x] `authenticate` - Verify JWT and attach user to request
  - [x] `requireRole(...roles)` - Role-based access control (RBAC)
  - [x] `requireEmailVerified` - Require verified email
  - [x] `requireSubscription(...tiers)` - Subscription tier gating
  - [x] `validateSession` - Active session validation with timeout
  - [x] `optionalAuth` - Optional authentication (public routes)
  - [x] `logSecurityEvent(type, severity)` - Security event logging

> ✅ **Complete**: Full JWT authentication system with token management, RBAC, session validation, and security logging

### 14.3 Password Security & Validation ✅ **COMPLETED**
- [x] Create `backend/src/utils/password.js`:
  - [x] `hash(password)` - bcrypt password hashing with 12 rounds
  - [x] `verify(password, hash)` - Password verification
  - [x] `validateStrength(password)` - Comprehensive strength validation
    * Configurable requirements (min length, uppercase, lowercase, numbers, special chars)
    * 8-point scoring system
    * Strength levels: weak, medium, strong
    * Detailed feedback messages
    * Common password detection
  - [x] `generateSecureToken(length)` - Cryptographically secure tokens (32 bytes)
  - [x] `hashToken(token)` - SHA256 token hashing for storage
  - [x] `isCommonPassword(password)` - Check against common passwords list
- [x] Add password history checking (prevent reuse of last 5):
  - [x] `isPasswordInHistory(userId, newPassword, historyLimit)` - Check password reuse
  - [x] `updatePasswordWithHistory(userId, newPassword)` - Update with history tracking
  - [x] Added `passwordHistory` field to User model (array of last 5 hashes)
  - [x] Added `passwordChangedAt` timestamp tracking
- [x] Implement account lockout after failed attempts:
  - [x] `checkAccountLockout(userId)` - Check lockout status
  - [x] `recordFailedLogin(userId)` - Track failed attempts and lock account
  - [x] `resetFailedLoginAttempts(userId)` - Reset on successful login
  - [x] Added `failedLoginAttempts` field to User model
  - [x] Added `accountLockedUntil` field to User model
  - [x] Default: 5 failed attempts = 30 minute lockout
  - [x] Security event logging for failed logins and lockouts
- [x] Database migration: Added password security fields to User model
- [x] Placeholder methods for future 2FA/TOTP implementation

> ✅ **Complete**: Full password security system with bcrypt hashing, strength validation, password history, account lockout, and secure token generation

### 14.4 Email Service Integration ✅ **COMPLETED**
- [x] Set up email service with Nodemailer + Gmail SMTP:
  - [x] `sendVerificationEmail(user, token)` - Email verification with 24h expiry
  - [x] `sendPasswordResetEmail(user, token)` - Password reset with 1h expiry
  - [x] `sendPasswordChangeNotification(user)` - Password change alerts
  - [x] `sendLoginNotification(user, deviceInfo)` - New device login alerts
  - [x] `generateEmailTemplate(type, data)` - Professional HTML templates
  - [x] `validateEmailDelivery(messageId)` - Delivery status tracking
  - [x] `testConnection()` - SMTP configuration validation
  - [x] `createTransporter()` - Nodemailer transporter setup
  - [x] `logEmailDelivery(data)` - Database logging for tracking
- [x] Create professional email templates with MotoLens branding:
  - [x] Electric Blue gradient header (#0ea5e9)
  - [x] Responsive design (mobile-optimized)
  - [x] Clear call-to-action buttons
  - [x] Security warnings for sensitive actions
  - [x] Footer with branding and legal notices
  - [x] 4 complete templates: verification, password reset, password changed, login notification
- [x] Add email delivery tracking:
  - [x] Message ID tracking
  - [x] Security event logging for all emails
  - [x] Failed delivery error logging
  - [x] Status validation with `validateEmailDelivery()`
- [x] Error handling:
  - [x] Comprehensive try-catch blocks
  - [x] Non-critical failures don't block operations
  - [x] Console error logging
  - [x] Database failure logging

> ✅ **Complete**: Full email service with Nodemailer, 4 professional HTML templates, delivery tracking, and comprehensive error handling. Free Gmail SMTP (500 emails/day)

### 14.5 Authentication Routes Implementation ✅ **COMPLETED**
- [x] Create `backend/src/routes/auth.js`:
  ```javascript
  // Registration & Login
  POST /api/auth/register
  POST /api/auth/login
  POST /api/auth/logout
  POST /api/auth/logout-all
  POST /api/auth/refresh-token
  GET /api/auth/me
  
  // Profile Management
  PUT /api/auth/profile
  PUT /api/auth/change-password
  POST /api/auth/upload-avatar
  
  // Password Recovery
  POST /api/auth/forgot-password
  POST /api/auth/reset-password
  
  // Email Verification
  POST /api/auth/verify-email
  POST /api/auth/resend-verification
  
  // Session Management
  GET /api/auth/sessions
  DELETE /api/auth/sessions/:sessionId
  DELETE /api/auth/sessions
  ```
- [x] Add comprehensive input validation for all endpoints
- [x] Implement rate limiting (10 login attempts per 15 minutes)
- [x] Add audit logging for security events
- [x] Test all endpoints with Postman/Thunder Client

**Estimated Time:** 10-12 hours

---

## 🎯 Phase 15: Security & Production Features

### 15.1 Advanced Security Implementation ✅ **COMPLETED**
- [x] Add comprehensive rate limiting:
  ```javascript
  const rateLimits = {
    login: rateLimit({
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 10, // 10 attempts per IP
      message: 'Too many login attempts'
    }),
    register: rateLimit({
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 3, // 3 registrations per IP
      message: 'Too many registration attempts'
    }),
    passwordReset: rateLimit({
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 3, // 3 reset attempts per email
      message: 'Too many password reset attempts'
    })
  };
  ```
- [x] Implement CORS security for production
- [x] Add helmet.js for security headers
- [x] Implement input sanitization and validation
- [x] Add SQL injection protection (Prisma handles this)
- [x] Implement XSS prevention
- [x] Add CSRF protection for web routes

### 15.2 Session Management & Device Tracking
- [ ] Implement comprehensive session tracking:
  ```javascript
  class SessionManager {
    static async createSession(userId, deviceInfo, ipAddress);
    static async validateSession(sessionToken);
    static async revokeSession(sessionId);
    static async revokeAllUserSessions(userId);
    static async cleanExpiredSessions();
    
    static async getUserActiveSessions(userId);
    static async detectSuspiciousActivity(userId);
    static async sendLoginAlerts(userId, deviceInfo);
  }
  ```
- [ ] Add device fingerprinting (OS, browser, etc.)
- [ ] Implement session limits per user (max 5 devices)
- [ ] Add suspicious login detection
- [ ] Send email notifications for new device logins

### 15.3 Admin Panel & User Management
- [ ] Create admin authentication middleware:
  ```javascript
  const requireAdmin = (req, res, next) => {
    if (req.user.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Admin access required' });
    }
    next();
  };
  ```
- [ ] Implement admin routes:
  ```javascript
  // User Management
  GET /api/admin/users
  GET /api/admin/users/:id
  PUT /api/admin/users/:id
  DELETE /api/admin/users/:id
  
  // Analytics & Monitoring
  GET /api/admin/analytics/users
  GET /api/admin/analytics/logins
  GET /api/admin/security/events
  GET /api/admin/sessions/active
  ```
- [ ] Add user search and filtering capabilities
- [ ] Implement bulk user operations
- [ ] Add analytics dashboard data endpoints
- [ ] Create security monitoring endpoints

### 15.4 Subscription & Role Management
- [ ] Implement subscription tier checking:
  ```javascript
  const checkSubscriptionLimit = (tier, feature) => {
    return async (req, res, next) => {
      const user = await User.findById(req.user.id);
      const limits = SUBSCRIPTION_LIMITS[tier][feature];
      
      if (await hasExceededLimit(user, feature, limits)) {
        return res.status(429).json({ 
          error: 'Subscription limit exceeded',
          upgrade: true 
        });
      }
      next();
    };
  };
  ```
- [ ] Add feature flags for subscription tiers
- [ ] Implement usage tracking (VIN scans, API calls)
- [ ] Add subscription upgrade/downgrade logic
- [ ] Create billing integration endpoints (future)

**Estimated Time:** 6-8 hours

---

## 🎯 Phase 16: Flutter Mobile Vehicle Features

### 16.1 VIN Scanner & Input Screen
- [ ] Create `lib/screens/vehicle/vin_scanner_screen.dart`
- [ ] Integrate camera permission handling (iOS & Android)
- [ ] Implement VIN barcode scanning (if VINs have barcodes) or OCR
- [ ] Create manual VIN input screen with validation:
  - [ ] 17-character validation
  - [ ] Uppercase transformation (JetBrains Mono font)
  - [ ] Real-time format checking
  - [ ] Sample VIN button for testing
- [ ] Add VIN scan history:
  - [ ] Recent scans list (local + synced)
  - [ ] Quick re-scan from history
  - [ ] Offline scan caching
- [ ] Connect to backend `/api/vin/decode` endpoint
- [ ] Display loading states with MotoLens branding
- [ ] Handle API errors gracefully

### 16.2 Vehicle Information Display
- [ ] Create `lib/screens/vehicle/vehicle_detail_screen.dart`
- [ ] Display decoded vehicle metadata:
  - [ ] Make, Model, Year (large, prominent)
  - [ ] Engine, Body Type, Trim
  - [ ] VIN display (JetBrains Mono, Electric Blue)
  - [ ] Vehicle summary (5 AI-generated bullets)
- [ ] Fetch and display vehicle images from backend
- [ ] Add favorite/bookmark functionality
- [ ] Implement share vehicle details feature
- [ ] Add back navigation to scan new VIN

### 16.3 360° Vehicle Viewer (Flutter Implementation)
- [ ] Research Flutter 360° image viewer packages:
  - [ ] Option 1: `panorama` package
  - [ ] Option 2: `flutter_cube` for 3D rotation
  - [ ] Option 3: Custom gesture-based implementation
- [ ] Implement touch/swipe rotation:
  - [ ] Pinch to zoom (optional)
  - [ ] Smooth drag sensitivity
  - [ ] Rotation instructions overlay
- [ ] Load 8 angle images from backend web search
- [ ] Add image preloading and caching
- [ ] Professional loading states
- [ ] Test performance on mid-range Android devices

### 16.4 Interactive Parts Hotspot System
- [ ] Port hotspot system from PWA to Flutter:
  - [ ] SVG overlay on vehicle images
  - [ ] Red dot + connecting line diagram aesthetic
  - [ ] White label boxes for part names
  - [ ] Smart label positioning (left/right based on location)
- [ ] Implement touch detection on hotspots:
  - [ ] 44px+ tap targets for glove-friendly use
  - [ ] Visual feedback (pulse animations, Electric Blue highlights)
  - [ ] Haptic feedback on tap
- [ ] Load 29 common parts from hotspot data:
  - [ ] Engine components, body panels, wheels, electrical
  - [ ] Mapped across 8 viewing angles
- [ ] Add toggle button to show/hide overlay
- [ ] Persistent state across angle rotation

### 16.5 Part Detail & Spare Parts
- [ ] Create `lib/screens/parts/part_detail_screen.dart`:
  - [ ] Part name and function description
  - [ ] Common failure symptoms
  - [ ] Related spare parts (max 5)
  - [ ] OEM part numbers (JetBrains Mono)
  - [ ] Aftermarket alternatives
  - [ ] Price comparison
  - [ ] Installation difficulty rating
- [ ] Create `lib/widgets/parts/spare_parts_list.dart`:
  - [ ] Filter by vehicle system (engine, electrical, body)
  - [ ] Availability status indicators
  - [ ] Price ranges (OEM vs aftermarket)
  - [ ] Installation guides
- [ ] Connect to backend spare parts APIs:
  - [ ] `/api/parts/identify`
  - [ ] `/api/parts/spare-parts`
- [ ] Add shopping cart functionality (optional)
- [ ] Implement part search within vehicle

### 16.6 Offline Support & Caching
- [ ] Implement offline VIN scan storage
- [ ] Cache vehicle data locally using `shared_preferences`
- [ ] Cache vehicle images using `cached_network_image`
- [ ] Add sync indicator when online
- [ ] Queue API calls for when connectivity returns
- [ ] Add "Offline Mode" indicator in UI

**Estimated Time:** 12-16 hours

---

## 🎯 Phase 17: Integration Testing & Deployment (Mobile-Focused)

### 17.1 End-to-End Mobile Testing
- [ ] Test complete Flutter authentication flow:
  - [ ] Registration → Email verification → Login → Dashboard
  - [ ] Password reset flow
  - [ ] Session management (logout from all devices)
  - [ ] Token refresh and expiry handling
  - [ ] Offline behavior and sync
- [ ] Test vehicle features:
  - [ ] VIN scanning/input → Vehicle display
  - [ ] 360° viewer performance
  - [ ] Parts hotspot interaction
  - [ ] Spare parts search and display
  - [ ] Offline caching and sync
- [ ] Test backend integration:
  - [ ] API response times
  - [ ] Error handling
  - [ ] Rate limiting
  - [ ] Image loading performance
- [ ] Device testing:
  - [ ] Android (various screen sizes)
  - [ ] iOS (if available)
  - [ ] Low-end devices (performance)
  - [ ] Different network conditions (3G, 4G, WiFi)

### 17.2 Security Audit
- [ ] Review Flutter secure storage implementation
- [ ] Test token management and refresh
- [ ] Verify API key security (not hardcoded)
- [ ] Test session hijacking prevention
- [ ] Review backend security (from Phase 15)
- [ ] Fix any identified vulnerabilities

### 17.3 Mobile App Deployment
- [ ] **Android Deployment:**
  - [ ] Configure app signing (keystore)
  - [ ] Set up Google Play Console account
  - [ ] Create app listing (screenshots, description)
  - [ ] Configure app permissions
  - [ ] Generate signed APK/AAB
  - [ ] Submit to Google Play (internal testing track first)
  - [ ] Test with beta testers

- [ ] **iOS Deployment (Optional - if budget allows):**
  - [ ] Set up Apple Developer account ($99/year)
  - [ ] Configure signing certificates
  - [ ] Create App Store Connect listing
  - [ ] Generate signed IPA
  - [ ] Submit to TestFlight for beta testing
  - [ ] Submit to App Store

- [ ] **Backend Production:**
  - [ ] Deploy to production hosting (Railway, Render, or AWS)
  - [ ] Configure production database (PostgreSQL)
  - [ ] Set up SSL/TLS certificates
  - [ ] Configure monitoring and alerts
  - [ ] Test production API endpoints

### 17.4 Post-Launch Monitoring
- [ ] Set up crash reporting (Firebase Crashlytics)
- [ ] Add analytics (Firebase Analytics or Mixpanel)
- [ ] Monitor API usage and costs
- [ ] Track user feedback
- [ ] Monitor backend performance
- [ ] Set up automated alerts for errors

**Estimated Time:** 8-10 hours

---

---

## 📊 Updated Time Estimate Summary (Mobile-Focused)

| Phase | Task | Estimated Time | Priority | Status |
|-------|------|----------------|----------|--------|
| 3 | Backend API Setup | 4-6 hours | **CRITICAL** | ✅ **COMPLETED** |
| 12 | Flutter Auth UI Setup | 6-8 hours | **CRITICAL** | ✅ **COMPLETED** |
| 13 | Flutter Auth Screens | 8-10 hours | **CRITICAL** | ✅ **COMPLETED** |
| 14 | Backend Production Auth | 10-12 hours | **HIGH** | **15.1 COMPLETED**, 15.2-15.4 ⏳ |
| 15 | Security & Production Features | 6-8 hours | **HIGH** | **15.1 COMPLETED**, 15.2-15.4 ⏳ |
| 16 | Flutter Vehicle Features | 12-16 hours | **HIGH** | ⏳ **PENDING** |
| 17 | Integration & Deployment | 8-10 hours | **MEDIUM** | ⏳ **PENDING** |
| **Total** | **Mobile App MVP** | **54-70 hours** | | **3/7 Phases Complete** |

**Realistic Timeline:** 6-8 weeks for complete mobile app with production backend

**Deprioritized (Not Included in Timeline):**
- Phases 1-2: React PWA Setup
- Phases 4-8: React PWA Frontend
- Phase 9-10: PWA Testing & Deployment

---

## 🚨 Critical Dependencies & Order (Mobile-Focused)

**Phase Order (Must Follow Sequence):**

1. **Phase 3 (Backend API Setup)** ✅ **COMPLETED**
   - ✅ Auto.dev VIN decoding API
   - ✅ Web image search (SerpApi)
   - ✅ Gemini AI integration for parts info
   - ✅ Vehicle and parts endpoints

2. **Phase 12 & 13 (Flutter Mobile Auth UI)** ✅ **COMPLETED**
   - ✅ Splash screen with auto-login
   - ✅ Login screen with brand styling
   - ✅ 2-step registration (simplified for mechanics)
   - ✅ Password reset request flow
   - ✅ Token-based password reset with strength indicator
   - ⏳ Change password (authenticated users) - Optional/Future

3. **Phase 14 (Backend Production Auth System)** 🔄 **IN PROGRESS**
   - ✅ 14.1: Database schema & Prisma setup - COMPLETED
   - ✅ 14.2: JWT utilities & token management - COMPLETED
   - ✅ 14.3: Password security & validation - COMPLETED
   - ✅ 14.4: Email service integration - COMPLETED
   - ✅ 14.5: Authentication routes - COMPLETED

4. **Phase 15 (Security & Production Features)** 🔄 **IN PROGRESS**
   - ✅ 15.1: Advanced security implementation (Helmet, rate limiting, CSRF, XSS, SQL injection) - COMPLETED
   - ⏳ 15.2: Session management & device tracking - PENDING
   - ⏳ 15.3: Admin panel & user management - PENDING
   - ⏳ 15.4: Subscription & role management - PENDING

5. **Phase 16 (Flutter Vehicle Features)** ⏳ **PENDING**
   - VIN scanner/input
   - Vehicle display & 360° viewer
   - Interactive parts hotspots
   - Spare parts browsing
   - Offline support

6. **Phase 17 (Mobile Integration & Deployment)** ⏳ **PENDING**
   - End-to-end testing
   - Security audit
   - Google Play deployment
   - Production backend deployment

**Key Blockers:**
- ✅ ~~Flutter auth UI design must be completed~~ - DONE!
- ✅ ~~Backend APIs must be working~~ - DONE!
- Backend production auth must be stable before Phase 16
- Security features (Phase 15.2-15.4) needed before production
- Integration testing requires all components working

**PWA Development:**
- ❌ Deprioritized - Not blocking mobile app development
- ❌ Phases 1-2, 4-8 skipped
- ❌ No React frontend work required for mobile MVP

---

## 🔧 Technology Stack Summary (Mobile-Focused)

**Flutter Mobile App:**
- `flutter_secure_storage` (v10.0.0) - Secure token storage
- `provider` (v6.1.1) - State management
- `http` (v1.1.0) - API communication
- `form_builder_validators` (v11.3.0) - Form validation
- `shared_preferences` (v2.2.2) - User preferences
- `cached_network_image` - Image caching
- Flutter camera/barcode scanner (for VIN scanning)
- 360° image viewer package (panorama or flutter_cube)

**Backend (Node.js + Express):**
- `prisma` (v6.2.0) - Database ORM and migrations
- `jsonwebtoken` (v9.0.2) - JWT token handling
- `bcryptjs` (v2.4.3) - Password hashing
- `express-rate-limit` (v7.5.0) - Brute force protection
- `helmet` (v8.0.0) - Security headers
- `nodemailer` (v6.9.x) - Email services
- `express-validator` (v7.2.1) - Input validation

**Backend APIs (External):**
- Auto.dev - VIN decoding (1,000 free/month)
- SerpApi - Vehicle image search (1,000 free/month)
- Google Gemini - AI-generated parts info (free tier)

**Database:**
- PostgreSQL - Production database
- Prisma migrations - Schema management (10 tables)

**Security:**
- JWT access tokens (15 min expiry)
- Refresh tokens (7 day expiry)
- bcrypt password hashing (12 rounds)
- Rate limiting on auth endpoints
- Session tracking and management
- Helmet.js security headers
- Input sanitization, XSS, CSRF, SQL injection protection

**Deployment:**
- Mobile: Google Play Store (Android)
- Backend: Railway, Render, or AWS
- Database: Managed PostgreSQL (AWS RDS or similar)
- Email: Free Gmail SMTP (500/day)

**Deprioritized (PWA Stack):**
- ❌ React + TypeScript
- ❌ Vite + PWA plugin
- ❌ Mantine UI
- ❌ React Router
- ❌ Vercel/Netlify deployment

---

## 💰 Updated Budget Impact (Mobile-Focused)

**Monthly Recurring Costs:**
- PostgreSQL hosting: $25-100/month
- Backend hosting (Railway/Render): $10-30/month
- Email service (Gmail SMTP): $0 (free - 500/day)
- Auto.dev API: $0 (under 1,000 calls/month)
- SerpApi: $0 (under 1,000 searches/month)
- Gemini API: $0 (free tier)
- **Total Monthly: $35-130**

**One-Time Costs:**
- Google Play Developer account: $25 (one-time)
- SSL certificates: $0 (Let's Encrypt)
- Domain (optional): $10-15/year
- **Total One-Time: $25-40**

**Optional (Deprioritized):**
- Apple Developer account for iOS: $99/year (NOT included in budget)
- PWA hosting (Vercel/Netlify): $0 (free tier) - NOT needed for mobile-only

**Development Time Budget:**
- Phase 3 (Backend API): ✅ Completed
- Phase 12-13 (Flutter Auth UI): ✅ Completed
- Phase 14-15 (Backend Auth + Security): 🔄 Partially complete (15.1 done)
- Phase 16 (Flutter Vehicle Features): ⏳ 12-16 hours remaining
- Phase 17 (Testing & Deployment): ⏳ 8-10 hours remaining
- **Total Remaining: 20-26 hours**

**Budget Status:**
- Under $1,000 target: ✅ **YES** ($35-130/month + $25-40 one-time)
- First year total: ~$445-$1,600 (depending on traffic/usage)
- MVP achievable within budget

**Savings from Mobile-Only Approach:**
- No PWA hosting costs
- No separate web frontend development time
- No cross-platform sync complexity initially
- Focus on single platform = faster time to market

---

*Last Updated: February 5, 2026*  
*Status: Mobile App Development - Backend Auth & Security in Progress*  
*Focus: Flutter Mobile App Only - PWA Deprioritized*

---

## 🚫 DEPRIORITIZED: React PWA Phases (For Future Reference)

> **Note:** The following phases are **NOT** part of current mobile app development.  
> They are documented here for potential future web frontend work.

<details>
<summary><strong>Click to expand deprioritized PWA phases</strong></summary>

## 🎯 Phase 1: PWA Project Setup & Foundation (DEPRIORITIZED)

### 1.1 Initialize Project Structure
- [x] Create Vite + React + TypeScript project
- [x] Configure Mantine UI
- [x] Install custom fonts (Inter + JetBrains Mono)
- [x] Install and configure vite-plugin-pwa
- [x] Set up project folder structure

### 1.2 Environment Configuration
- [x] Create `.env` file structure
- [x] Set up environment variables
- [x] Add `.env.example` template
- [x] Update `.gitignore` for secrets

### 1.3 Development Tools
- [x] Configure ESLint for React + TypeScript
- [x] Set up Prettier
- [x] Add basic npm scripts
- [x] Test PWA installability

### 1.4 Design System Implementation
- [x] Create theme configuration
- [x] Define MotoLens color palette
- [x] Configure Mantine theme
- [x] Set up font loading

---

## 🎯 Phase 2: PWA Authentication & Routing (DEPRIORITIZED)

### 2.1 Dummy Authentication System
- [x] Create `AuthContext.tsx`
- [x] Implement dummy auth logic (admin/admin)
- [x] Store auth state in localStorage
- [x] Create `useAuth` custom hook

### 2.2 Login Page
- [x] Create `LoginPage.tsx`
- [x] Design mobile-first login form
- [x] Apply brand styling
- [x] Implement validation
- [x] Test on mobile devices

### 2.3 Protected Routes
- [x] Install react-router-dom
- [x] Set up routing structure
- [x] Create `ProtectedRoute` component
- [x] Implement route guards

---

## 🎯 Phase 4: PWA Frontend - VIN Input & Vehicle Display (DEPRIORITIZED)

### 4.1 VIN Input Page
- [x] Create `VinInputPage` component
- [x] Design mobile-first layout
- [x] Add Mantine TextInput for VIN
- [x] Add submit button
- [x] Implement loading state
- [x] Handle API errors
- [x] Add sample VIN button
- [x] Add logout button

### 4.2 Vehicle Service Layer
- [x] Create `vehicleService.ts`
- [x] Implement `decodeVIN(vin: string)`
- [x] Implement `getVehicleImages()`
- [x] Implement `getVehicleSummary()`
- [x] Add TypeScript interfaces
- [x] Add error handling

### 4.3 Vehicle Display Page
- [x] Create `VehicleViewPage` component
- [x] Display vehicle metadata
- [x] Add AI-generated summary
- [x] Style with brand colors
- [x] Add back button
- [x] Add logout option

---

## 🎯 Phase 5: PWA 360° Car Viewer (DEPRIORITIZED)

### 5.1 Install react-360-view
- [x] Install package
- [x] Test with sample images
- [x] Configure for mobile touch/swipe
- [x] Set up drag sensitivity
- [x] Add loading spinner

### 5.2 Integrate Web Image Search
- [x] Load 8 angle images
- [x] Display in 360° viewer
- [x] Add image preloading
- [x] Replace Gemini with SerpApi
- [x] Test with German vehicles
- [x] Update frontend

### 5.3 Viewer UI Polish
- [x] Add rotation instructions
- [x] Remove angle indicator text
- [x] Smooth loading transitions
- [ ] Add pinch-to-zoom (optional)

---

## 🎯 Phase 6: PWA Parts Interaction System (DEPRIORITIZED)

### 6.1 SVG Hotspot System
- [x] Create `PartsOverlay` component
- [x] Define hotspot data structure
- [x] Implement diagram-style hotspot rendering
- [x] Add tap/click detection
- [x] Visual feedback
- [x] Persistent state
- [x] Mobile-optimized

### 6.2 Part Detail Modal
- [x] Create `PartDetailModal` component
- [x] Style with brand colors
- [x] Fetch part info from backend
- [x] Display comprehensive part data
- [x] Professional interactions

### 6.3 Hotspot Data & Spare Parts
- [x] Create JSON file with 29 common parts
- [x] Expand part data
- [x] Create spare parts components
- [x] Test tap accuracy

---

## 🎯 Phase 7: PWA Spare Parts Components (DEPRIORITIZED)

### 7.1 Spare Parts List Display
- [x] Create `SparePartsList` component
- [x] Design with arrow styling
- [x] Display spare parts data
- [x] Integrate with hotspot data
- [x] Filter by vehicle system

### 7.2 Part Detail Pages
- [x] Create detailed part pages
- [x] Visual connection to hotspots
- [x] Comprehensive part information
- [x] Shopping integration

### 7.3 Visual Consistency System
- [x] Create design tokens
- [x] Standardize animation patterns
- [x] Mobile optimization

---

## 🎯 Phase 8: PWA Features & Polish (DEPRIORITIZED)

### 8.1 PWA Manifest & Icons
- [ ] Create app icons with brand colors
- [ ] Configure `manifest.json`
- [ ] Test install prompt

### 8.2 Service Worker Configuration
- [ ] Configure workbox
- [ ] Cache app shell
- [ ] Add offline fallback
- [ ] Test offline behavior
- [ ] Add update notification

### 8.3 Mobile Optimizations
- [ ] Test on real devices
- [ ] Ensure tap targets ≥44px
- [ ] Test with gloves
- [ ] Optimize for 3G
- [ ] Add loading skeletons
- [ ] Test in sunlight

### 8.4 Brand Consistency Check
- [ ] Review color usage
- [ ] Verify font loading
- [ ] Check Electric Blue accents
- [ ] Test contrast ratios

---

## 🎯 Phase 9: PWA Testing & Refinement (DEPRIORITIZED)

### 9.1 Functionality Testing
- [ ] Test login → VIN → parts flow
- [ ] Test with German vehicle VINs
- [ ] Test error handling
- [ ] Test offline behavior
- [ ] Test PWA install

### 9.2 Performance Testing
- [ ] Measure page load times
- [ ] Check image loading
- [ ] Test on 3G
- [ ] Optimize bundle size
- [ ] Run Lighthouse audit

### 9.3 UX Testing
- [ ] Test one-handed usage
- [ ] Verify tap targets
- [ ] Check text readability
- [ ] Test with mechanic
- [ ] Gather feedback

### 9.4 Bug Fixes & Polish
- [ ] Fix bugs
- [ ] Smooth animations
- [ ] Add loading states
- [ ] Improve error messages
- [ ] Final polish

---

## 🎯 Phase 10: PWA Deployment (DEPRIORITIZED)

### 10.1 Frontend Deployment
- [ ] Build production bundle
- [ ] Test production build
- [ ] Deploy to Vercel/Netlify
- [ ] Configure custom domain
- [ ] Test PWA install from live URL
- [ ] Verify HTTPS

### 10.2 API Keys & Monitoring
- [ ] Verify API keys in production
- [ ] Set up usage monitoring
- [ ] Set up budget alerts
- [ ] Document API costs

### 10.3 Documentation
- [ ] Update README
- [ ] Create user guide
- [ ] Document API endpoints

---

## 🎯 Phase 16 Alternative: PWA Auth Migration (DEPRIORITIZED)

### PWA Authentication Service Update
- [ ] Update `frontend/src/services/authApi.ts`
- [ ] Replace localStorage with cookies
- [ ] Add automatic token refresh
- [ ] Implement error handling
- [ ] Add connectivity detection

### PWA Auth Context Migration
- [ ] Update `AuthContext.tsx`
- [ ] Add token refresh timer
- [ ] Session validation on startup
- [ ] Error boundary for auth
- [ ] Backward compatibility

### Registration & Profile UI
- [ ] Create PWA registration components
- [ ] Update login form
- [ ] Add profile management page
- [ ] Responsive design
- [ ] Form validation

### Cross-Platform Data Sync
- [ ] VIN scan history sync
- [ ] Scan history API endpoints
- [ ] Offline caching with sync
- [ ] User preferences sync
- [ ] Data export (GDPR)

</details>

---

*End of Deprioritized PWA Sections*
