# 📋 MOTO LENS - Development Tasks

1HGCM82633A123456 <!-- Test VIN: 2003 Honda Accord -->
<!-- Invalid VIN example: WVWZZZCDZMW072001 (shows validation warnings) -->

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

### 14.3 Password Security & Validation
- [ ] Create `backend/src/utils/password.js`:
  ```javascript
  const bcrypt = require('bcryptjs');
  
  class PasswordUtil {
    static async hash(password) {
      const saltRounds = 12;
      return await bcrypt.hash(password, saltRounds);
    }
    
    static async verify(password, hash) {
      return await bcrypt.compare(password, hash);
    }
    
    static validateStrength(password) {
      const requirements = {
        minLength: password.length >= 8,
        hasUppercase: /[A-Z]/.test(password),
        hasLowercase: /[a-z]/.test(password),
        hasNumbers: /\d/.test(password),
        hasSpecialChar: /[!@#$%^&*(),.?":{}|<>]/.test(password)
      };
      
      const score = Object.values(requirements).filter(Boolean).length;
      return { requirements, score, isValid: score >= 4 };
    }
    
    static generateSecureToken() {
      return crypto.randomBytes(32).toString('hex');
    }
  }
  ```
- [ ] Add password history checking (prevent reuse of last 5)
- [ ] Implement account lockout after failed attempts
- [ ] Add password expiry warnings (optional)

### 14.4 Email Service Integration
- [ ] Set up email service (SendGrid or Nodemailer):
  ```javascript
  class EmailService {
    static async sendVerificationEmail(user, token);
    static async sendPasswordResetEmail(user, token);
    static async sendPasswordChangeNotification(user);
    static async sendLoginNotification(user, deviceInfo);
    
    static generateEmailTemplate(type, data);
    static validateEmailDelivery(messageId);
  }
  ```
- [ ] Create professional email templates with MotoLens branding
- [ ] Add email delivery tracking
- [ ] Implement email queue for high volume
- [ ] Add unsubscribe functionality

### 14.5 Authentication Routes Implementation  
- [ ] Create `backend/src/routes/auth.js`:
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
- [ ] Add comprehensive input validation for all endpoints
- [ ] Implement rate limiting (10 login attempts per 15 minutes)
- [ ] Add audit logging for security events
- [ ] Test all endpoints with Postman/Thunder Client

**Estimated Time:** 10-12 hours

---

## 🎯 Phase 15: Security & Production Features

### 15.1 Advanced Security Implementation
- [ ] Add comprehensive rate limiting:
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
- [ ] Implement CORS security for production
- [ ] Add helmet.js for security headers
- [ ] Implement input sanitization and validation
- [ ] Add SQL injection protection (Prisma handles this)
- [ ] Implement XSS prevention
- [ ] Add CSRF protection for web routes

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

## 🎯 Phase 16: React PWA Auth Migration & Integration

### 16.1 PWA Authentication Service Update
- [ ] Update `frontend/src/services/authApi.ts`:
  ```typescript
  export class AuthAPI {
    private static baseURL = process.env.REACT_APP_API_URL || 'http://localhost:3001/api';
    
    static async login(email: string, password: string): Promise<AuthResponse> {
      const response = await fetch(`${this.baseURL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include', // Include cookies for refresh tokens
        body: JSON.stringify({ 
          email, 
          password,
          deviceType: 'web',
          deviceName: navigator.userAgent 
        })
      });
      
      if (!response.ok) {
        throw new AuthError(await response.json());
      }
      
      return await response.json();
    }
    
    static async refreshToken(): Promise<AuthResponse>;
    static async register(data: RegisterRequest): Promise<AuthResponse>;
    static async logout(): Promise<void>;
    static async getCurrentUser(): Promise<User>;
  }
  ```
- [ ] Replace localStorage with secure cookie-based refresh tokens
- [ ] Add automatic token refresh timing (14-minute intervals)
- [ ] Implement comprehensive error handling
- [ ] Add network connectivity detection

### 16.2 PWA Auth Context Migration
- [ ] Update `frontend/src/contexts/AuthContext.tsx`:
  ```typescript
  export function AuthProvider({ children }: { children: ReactNode }) {
    const [user, setUser] = useState<User | null>(null);
    const [isAuthenticated, setIsAuthenticated] = useState(false);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    
    // Auto token refresh
    useEffect(() => {
      let refreshTimer: NodeJS.Timeout;
      
      if (isAuthenticated) {
        refreshTimer = setInterval(async () => {
          try {
            await AuthAPI.refreshToken();
          } catch (error) {
            console.error('Token refresh failed:', error);
            handleLogout();
          }
        }, 14 * 60 * 1000); // 14 minutes
      }
      
      return () => clearInterval(refreshTimer);
    }, [isAuthenticated]);
  }
  ```
- [ ] Add comprehensive authentication state management
- [ ] Implement session validation on app startup  
- [ ] Add error boundary for auth failures
- [ ] Test backward compatibility with existing routes

### 16.3 Registration & Profile Management UI
- [ ] Create new PWA registration components:
  - [ ] `RegistrationForm.tsx` (professional multi-step design)
  - [ ] `EmailVerificationScreen.tsx`
  - [ ] `ProfileSetupForm.tsx`
  - [ ] `ForgotPasswordForm.tsx`
  - [ ] `ResetPasswordForm.tsx`
- [ ] Update login form to match new backend API
- [ ] Add user profile management page:
  - [ ] Profile information editing
  - [ ] Password change functionality
  - [ ] Session management (view/revoke active sessions)
  - [ ] Account deletion option
- [ ] Implement responsive design for all new screens
- [ ] Test form validation and error handling

### 16.4 Cross-Platform Data Sync
- [ ] Update VIN scan history to sync with backend:
  ```typescript
  interface VinScanRecord {
    id: string;
    userId: string;
    vinNumber: string;
    vehicleMake: string;
    vehicleModel: string;
    vehicleYear: number;
    partsIdentified: PartInfo[];
    scanSource: 'mobile' | 'web';
    scannedAt: Date;
  }
  ```
- [ ] Add scan history API endpoints to backend
- [ ] Implement offline scan caching with sync when online
- [ ] Add user preferences sync (theme, language, etc.)
- [ ] Create data export functionality (GDPR compliance)

**Estimated Time:** 6-8 hours

---

## 🎯 Phase 17: Integration Testing & Deployment

### 17.1 End-to-End Testing
- [ ] Test complete Flutter authentication flow:
  - [ ] Registration → Email verification → Login → Profile setup
  - [ ] Password reset flow
  - [ ] Session management (logout from all devices)
  - [ ] Token refresh and expiry handling
  - [ ] Offline behavior and sync
- [ ] Test React PWA auth migration:
  - [ ] Migration from dummy auth to real auth
  - [ ] Cross-platform session consistency
  - [ ] Data sync between mobile and web
  - [ ] Backward compatibility
- [ ] Test backend security:
  - [ ] Rate limiting effectiveness
  - [ ] SQL injection prevention 
  - [ ] XSS protection
  - [ ] CORS security
  - [ ] Token blacklisting
- [ ] Performance testing:
  - [ ] Database query optimization
  - [ ] API response times
  - [ ] Mobile app startup time
  - [ ] Token refresh performance

### 17.2 Security Audit & Penetration Testing
- [ ] Conduct comprehensive security review:
  - [ ] Password security (hashing, strength requirements)
  - [ ] JWT token security (secret strength, expiry, rotation)
  - [ ] Session management security
  - [ ] API endpoint security
  - [ ] Input validation coverage
- [ ] Test common attack vectors:
  - [ ] Brute force login attempts
  - [ ] SQL injection attempts
  - [ ] XSS attempts
  - [ ] CSRF attempts
  - [ ] Session hijacking
- [ ] Review and fix any security vulnerabilities
- [ ] Document security measures for compliance

### 17.3 Database Migration & Production Deployment
- [ ] Set up production PostgreSQL database:
  - [ ] Configure AWS RDS or managed PostgreSQL service
  - [ ] Set up automated backups
  - [ ] Configure connection pooling
  - [ ] Add database monitoring
- [ ] Deploy backend to production:
  - [ ] Choose hosting platform (Vercel, Railway, or AWS)
  - [ ] Configure environment variables
  - [ ] Set up SSL/TLS certificates
  - [ ] Configure domain and DNS
  - [ ] Test production API endpoints
- [ ] Deploy PWA updates:
  - [ ] Update API URLs to production
  - [ ] Test PWA functionality with production backend
  - [ ] Verify CORS configuration
- [ ] Set up monitoring and alerting:
  - [ ] Application monitoring (Sentry or similar)
  - [ ] Database monitoring
  - [ ] API usage tracking
  - [ ] Security event monitoring

### 17.4 Migration Strategy & Rollback Plan
- [ ] Create migration strategy for existing users:
  - [ ] Data export from current dummy auth system
  - [ ] User notification about auth system upgrade
  - [ ] Graceful transition period
  - [ ] Support for users who need help migrating
- [ ] Implement feature flags:
  - [ ] Toggle between old and new auth systems
  - [ ] Gradual rollout capability
  - [ ] A/B testing support
- [ ] Create rollback procedures:
  - [ ] Database rollback scripts
  - [ ] Frontend rollback deployment
  - [ ] Backend rollback deployment
  - [ ] User communication plan for rollbacks

**Estimated Time:** 8-10 hours

---

## 📊 Updated Time Estimate Summary

| Phase | Task | Estimated Time | Priority | Status |
|-------|------|----------------|----------|--------|
| 12 | Flutter Auth UI Setup | 6-8 hours | **HIGHEST** | ✅ **COMPLETED** |
| 13 | Flutter Auth Screens | 8-10 hours | **HIGHEST** | ✅ **COMPLETED** |
| 14 | Backend Auth System | 10-12 hours | **HIGH** | 🔄 **NEXT** |
| 15 | Security & Production Features | 6-8 hours | **HIGH** | ⏳ **PENDING** |
| 16 | PWA Auth Migration | 6-8 hours | **MEDIUM** | ⏳ **PENDING** |
| 17 | Integration & Deployment | 8-10 hours | **MEDIUM** | ⏳ **PENDING** |
| **Total** | **Full Production Auth** | **44-56 hours** | | **2/5 Phases Complete** |

**Realistic Timeline:** 6-7 weeks for complete production authentication system

---

## 🚨 Critical Dependencies & Order

**Phase Order (Must Follow Sequence):**

1. **Phase 12 & 13 (Flutter Mobile Auth UI)** ✅ **COMPLETED**
   - ✅ Splash screen with auto-login
   - ✅ Login screen with brand styling
   - ✅ 2-step registration (simplified for mechanics)
   - ✅ Password reset request flow
   - ✅ Token-based password reset with strength indicator
   - ⏳ Change password (authenticated users) - Optional/Future

2. **Phase 14 (Backend Auth System)** 🔄 **NEXT PRIORITY**
   - Database schema & Prisma setup
   - JWT utilities & token management
   - Password security & validation
   - Email service integration
   - Authentication API endpoints

3. **Phase 15 (Security Features)** - Builds on backend
4. **Phase 16 (PWA Migration)** - After backend is stable
5. **Phase 17 (Integration & Deployment)** - Final phase

**Key Blockers:**
- ✅ ~~Flutter UI design must be completed~~ - DONE!
- Backend APIs must be working before Flutter can be fully tested
- Backend APIs must be working before PWA migration
- Security features need complete backend before implementation
- Integration testing requires all components working

---

## 🔧 Technology Stack Summary

**Flutter Mobile:**
- `flutter_secure_storage` - Secure token storage
- `provider` - State management
- `http` - API communication
- `form_builder_validators` - Form validation

**Backend (Node.js):**
- `prisma` - Database ORM and migrations
- `jsonwebtoken` - JWT token handling
- `bcryptjs` - Password hashing
- `express-rate-limit` - Brute force protection
- `helmet` - Security headers
- `nodemailer` - Email services

**Database:**
- PostgreSQL - Production database
- Prisma migrations - Schema management

**Security:**
- JWT access tokens (15 min expiry)
- Refresh tokens (7 day expiry) 
- bcrypt password hashing (12 rounds)
- Rate limiting on auth endpoints
- Session tracking and management

---

## 💰 Updated Budget Impact

**New Costs for Production Auth:**
- PostgreSQL hosting: $25-100/month
- Email service (SendGrid): $15-50/month
- Additional backend hosting resources: $10-30/month
- SSL certificates: $0 (Let's Encrypt)
- **Total Additional Monthly: $50-180**

**One-time Development:**
- Additional development time: 44-56 hours
- Third-party integrations setup: Included
- Security audit (optional): $500-1000
- **Development Budget Impact: Time only (no additional service costs)**

---

*Last Updated: February 5, 2026*  
*Status: Ready to Begin Authentication Implementation*
