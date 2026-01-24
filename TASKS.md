# 📋 MOTO LENS - Development Tasks

WVWZZZCDZMW072001

## Project Overview
Building a mobile-first PWA for German vehicle VIN decoding and interactive part identification.

**Budget:** Under $1,000  
**Timeline:** MVP in 3-5 days  
**Target Users:** 1-2 daily users (mechanics)

---

## 🎯 Phase 1: Project Setup & Foundation

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

## 🔧 Technical Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Brand colors not visible in bright garage lighting | Test in real conditions; adjust Electric Blue brightness if needed |
| Fonts not loading properly | Host fonts locally as fallback |
| Web image search returns low quality images | Filter by size/quality; use multiple APIs (SerpApi + Bing + Google) |
| Auto.dev limited German coverage | Test thoroughly with German VINs; 1,000 free calls for thorough testing |
| Image search APIs return irrelevant results | Use specific queries; filter by relevance; combine multiple search terms |
| 360° viewer too slow with web images | Optimize image loading; use thumbnails; progressive enhancement |
| PWA install issues on iOS | Test on real devices; follow Apple PWA guidelines |
| Image search costs exceed budget | Use free tiers first; implement smart caching; limit searches per user |
| Login too simple (security concerns) | Document as MVP only; plan JWT implementation for production |

---

## 📝 Notes & Decisions

- **No database in MVP** - All data fetched on-demand or cached in-memory
- **Dummy authentication only** - Hardcoded admin/admin for MVP
- **Brand colors:** Carbon Black, Gunmetal Gray, Electric Blue
- **Fonts:** Inter (UI), JetBrains Mono (VINs/technical)
- **German vehicles only** - Focused scope for MVP
- **Web image search only** - No AI generation, real car photos from web
- **SerpApi + Bing + Google** - Multiple search APIs for best coverage
- **No user accounts** - Reduces complexity significantly
- **localStorage for auth state** - Simple session management

---

## ✅ Definition of Done

The MVP is complete when:

1. A mechanic can log in with admin/admin credentials
2. Logged-in mechanic can enter a German vehicle VIN
3. The app decodes it and shows vehicle info with brand styling
4. A 360° rotatable car view displays (brand colors)
5. Tapping parts shows relevant information in brand-styled modals
6. All info looks professional (not AI-generated)
7. The app installs as a PWA on mobile with brand icon/colors
8. It works in typical garage conditions (high contrast, one-handed)
9. Brand design system (Carbon Black, Gunmetal Gray, Electric Blue) is consistent throughout
10. Fonts (Inter & JetBrains Mono) are properly loaded and applied
11. Total spend is under $1,000

---

*Last Updated: January 23, 2026*  
*Status: Ready to Begin Development*
