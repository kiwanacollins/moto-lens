# 📋 MOTO LENS - Development Tasks

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

### 2.3 Google Gemini/Imagen Integration
- [x] Set up Google Cloud project
- [x] Enable Gemini API
- [x] Create service account / API key
- [x] Create `/api/vehicle/images` endpoint
- [x] Implement image generation with prompt template:
  ```
  Photorealistic studio image of a {YEAR} {MAKE} {MODEL},
  {ANGLE} view,
  neutral background,
  automotive photography,
  realistic lighting,
  high detail,
  sharp focus
  ```
- [x] Generate 8 angles: front, front-left, left, rear-left, rear, rear-right, right, front-right
- [x] Return image URLs or base64 data
- [x] Add caching mechanism (in-memory for MVP)

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

### 4.2 Integrate AI-Generated Images
- [ ] Load 8 angle images from backend
- [ ] Display in 360° viewer
- [ ] Add image preloading
- [ ] Optimize image sizes for mobile
- [ ] Add fallback for failed image loads
- [ ] Test rotation smoothness on mobile devices

### 4.3 Viewer UI Polish
- [x] Add rotation instructions (swipe hint) - Electric Blue text
- [ ] Add angle indicator (optional) - brand colors
- [x] Smooth loading transitions with brand styling
- [ ] Test performance on mid-range phones
- [ ] Add pinch-to-zoom (optional)

**Estimated Time:** 3-4 hours

---

## 🎯 Phase 6: Parts Interaction System

### 5.1 SVG Hotspot System
- [ ] Research SVG overlay technique
- [ ] Create `PartsOverlay` component
- [ ] Define hotspot data structure:
  ```typescript
  interface Hotspot {
    id: string;
    partName: string;
    angle: string;
    coordinates: { x: number; y: number };
    radius: number;
  }
  ```
- [ ] Implement hotspot rendering per angle
- [ ] Add tap/click detection
- [ ] Visual feedback on tap (Electric Blue ripple/highlight)

### 5.2 Part Detail Modal
- [ ] Create `PartDetailModal` component
- [ ] Style with brand colors:
  - [ ] Carbon Black background
  - [ ] Gunmetal Gray content area
  - [ ] Electric Blue accents
  - [ ] Inter font for descriptions
  - [ ] JetBrains Mono for part numbers
- [ ] Fetch part info from backend on tap
- [ ] Display:
  - [ ] Part name
  - [ ] Function description
  - [ ] Common failure symptoms
  - [ ] Related spare parts (max 5)
- [ ] Add close button (large tap target, Electric Blue)
- [ ] Smooth modal animations (Mantine)
- [ ] Mobile-optimized layout

### 5.3 Hotspot Data (MVP - Manual Entry)
- [ ] Create JSON file with common parts:
  - [ ] Engine hood
  - [ ] Front bumper
  - [ ] Headlights
  - [ ] Wheels/Tires
  - [ ] Side mirrors
  - [ ] Rear bumper
  - [ ] Tail lights
  - [ ] Brake calipers
- [ ] Map hotspots to appropriate angles
- [ ] Test tap accuracy on mobile

**Estimated Time:** 4-5 hours

---

## 🎯 Phase 7: PWA Features & Polish

### 6.1 PWA Manifest & Icons
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

### 6.2 Service Worker Configuration
- [ ] Configure workbox via vite-plugin-pwa
- [ ] Cache app shell (HTML, CSS, JS)
- [ ] Add offline fallback page
- [ ] Test offline behavior
- [ ] Add update notification when new version available

### 6.3 Mobile Optimizations
- [ ] Test on real devices (Android + iOS)
- [ ] Ensure tap targets are ≥44px
- [ ] Test with gloves (if possible)
- [ ] Optimize for slow 3G connections
- [ ] Add loading skeletons for better perceived performance
- [ ] Test in bright sunlight (contrast check)

### 6.4 Brand Consistency Check
- [ ] Review all pages for consistent color usage
- [ ] Verify Inter font is used for all UI text
- [ ] Verify JetBrains Mono for VINs and technical data
- [ ] Check Electric Blue accents are prominent but not overwhelming
- [ ] Test contrast ratios for accessibility
- [ ] Ensure Carbon Black/Gunmetal Gray backgrounds throughout

**Estimated Time:** 3-4 hours

---

## 🎯 Phase 8: Testing & Refinement

### 7.1 Functionality Testing
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

### 7.2 Performance Testing
- [ ] Measure page load times
- [ ] Check image loading performance
- [ ] Test on 3G connection
- [ ] Optimize bundle size if needed
- [ ] Run Lighthouse audit (PWA, Performance, Accessibility)

### 7.3 UX Testing
- [ ] Test one-handed usage
- [ ] Verify tap target sizes (≥44px)
- [ ] Check text readability with brand colors
- [ ] Test brand color visibility in different lighting
- [ ] Verify Electric Blue accents are visible in sunlight
- [ ] Test login flow smoothness
- [ ] Test with actual mechanic if possible
- [ ] Gather feedback and iterate

### 7.4 Bug Fixes & Polish
- [ ] Fix any identified bugs
- [ ] Smooth out animations
- [ ] Add loading states where missing
- [ ] Improve error messages
- [ ] Final design polish

**Estimated Time:** 3-4 hours

---

## 🎯 Phase 9: Deployment

### 8.1 Backend Deployment
- [ ] Choose hosting platform:
  - Option A: Vercel Serverless Functions (recommended for budget)
  - Option B: Railway
  - Option C: Render free tier
- [ ] Set up environment variables in hosting platform
- [ ] Deploy backend
- [ ] Test deployed endpoints
- [ ] Set up domain/subdomain if needed

### 8.2 Frontend Deployment
- [ ] Build production bundle (`npm run build`)
- [ ] Test production build locally
- [ ] Deploy to:
  - Option A: Vercel (recommended)
  - Option B: Netlify
  - Option C: Cloudflare Pages
- [ ] Configure custom domain (optional)
- [ ] Test PWA install from live URL
- [ ] Verify HTTPS is working

### 8.3 API Keys & Monitoring
- [ ] Verify all API keys are working in production
- [ ] Set up basic usage monitoring:
  - [ ] VINLink API usage
  - [ ] Gemini API usage
- [ ] Set up budget alerts if platform supports it
- [ ] Document API costs per request

### 8.4 Documentation
- [ ] Update README.md with:
  - [ ] Project description
  - [ ] Setup instructions
  - [ ] Environment variables needed
  - [ ] Deployment steps
- [ ] Create user guide (optional)
- [ ] Document API endpoints (for future reference)

**Estimated Time:** 2-3 hours

---

## 🎯 Phase 10: Post-Launch (Optional)

### 9.1 Monitoring & Feedback
- [ ] Monitor API costs daily
- [ ] Gather user feedback
- [ ] Track any errors/crashes
- [ ] Monitor performance metrics

### 9.2 Quick Wins
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
| 6 | Parts Interaction | 4-5 hours |
| 7 | PWA Features | 3-4 hours |
| 8 | Testing | 3-4 hours |
| 9 | Deployment | 2-3 hours |
| **Total** | | **27-37 hours** |

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
| Google Gemini/Imagen | Pay-per-request | $100-300 (image generation) |
| Hosting (Backend) | Free tier / $5-10/mo | $0-20 |
| Hosting (Frontend) | Free tier | $0 |
| Domain (optional) | $10-15/year | $0-15 |
| **Total** | | **$100-335** |

**Remaining budget for scaling:** $665-900

---

## 🔧 Technical Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Brand colors not visible in bright garage lighting | Test in real conditions; adjust Electric Blue brightness if needed |
| Fonts not loading properly | Host fonts locally as fallback |
| AI images look fake | Refine prompts; add "photorealistic" emphasis |
| Auto.dev limited German coverage | Test thoroughly with German VINs; 1,000 free calls for thorough testing |
| Gemini output sounds AI-generated | Use strict system prompt; implement output templates |
| 360° viewer too slow | Optimize image sizes; reduce to 8 images; add lazy loading |
| PWA install issues on iOS | Test on real devices; follow Apple PWA guidelines |
| Costs exceed budget | Implement aggressive caching; limit test requests |
| Login too simple (security concerns) | Document as MVP only; plan JWT implementation for production |

---

## 📝 Notes & Decisions

- **No database in MVP** - All data fetched on-demand or cached in-memory
- **Dummy authentication only** - Hardcoded admin/admin for MVP
- **Brand colors:** Carbon Black, Gunmetal Gray, Electric Blue
- **Fonts:** Inter (UI), JetBrains Mono (VINs/technical)
- **German vehicles only** - Focused scope for MVP
- **8 angles minimum** - Balance between quality and cost
- **Manual hotspot placement** - No AI-based detection in MVP
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
