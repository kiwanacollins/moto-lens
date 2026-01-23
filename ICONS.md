# MOTO LENS - Logo & Icons

## 🎨 Design Concept

The MOTO LENS logo combines automotive and optical elements to represent the app's purpose: precision vehicle part identification through a "lens" metaphor.

### Key Design Elements:

1. **Lens Circle** (Electric Blue #00D9FF)
   - Double-ring design suggesting camera/optical lens
   - Represents the "lens" through which mechanics view vehicle parts
   - Highlight effect adds depth and realism

2. **Crosshair Focus Markers** (Electric Blue)
   - Four directional lines suggesting precision and targeting
   - Represents the accuracy of VIN decoding and part identification
   - Evokes technical/professional feel

3. **Mechanical Gear** (Gunmetal Gray #2C3539)
   - Central gear element represents automotive/mechanical focus
   - Gear teeth add industrial character
   - Inner circle creates depth

4. **Corner Accents** (Electric Blue - optional)
   - Frame corners suggest viewfinder/camera interface
   - Adds technical sophistication
   - Can be hidden for simpler variants

### Brand Colors:
- **Carbon Black**: #0A0A0A (backgrounds)
- **Gunmetal Gray**: #2C3539 (secondary elements)
- **Electric Blue**: #00D9FF (primary accents/CTAs)

---

## 📁 Generated Files

### SVG Files (Vector - Scalable)
Located in `/public`:
- `logo.svg` - 512×512 main logo with rounded corners
- `icon-192.svg` - 192×192 smaller icon variant
- `icon-512-maskable.svg` - 512×512 adaptive/maskable icon for Android

### PNG Files (Raster - PWA Ready)
Generated in `/public`:
- `icon-512.png` - 512×512 PNG (main app icon)
- `icon-192.png` - 192×192 PNG (smaller PWA icon)
- `icon-512-maskable.png` - 512×512 PNG (adaptive icon with safe zone)

---

## 🔧 Usage

### In React Components
```tsx
import { MotoLensLogo } from './components/MotoLensLogo';

// With corners (default)
<MotoLensLogo size={120} />

// Without corner accents
<MotoLensLogo size={80} showCorners={false} />
```

### As Static Asset
```tsx
<img src="/logo.svg" alt="MOTO LENS" width="128" />
```

### In PWA Manifest
```json
{
  "icons": [
    {
      "src": "/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "/icon-512-maskable.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
```

---

## 🔄 Regenerating Icons

If you need to regenerate PNG files from SVG:

### Option 1: Using the included script (requires Node.js + sharp)
```bash
npm install --save-dev sharp
node scripts/generate-icons.js
```

### Option 2: Using sharp-cli (global install)
```bash
npm install -g sharp-cli
sharp -i public/logo.svg -o public/icon-512.png resize 512 512
sharp -i public/icon-192.svg -o public/icon-192.png resize 192 192
sharp -i public/icon-512-maskable.svg -o public/icon-512-maskable.png resize 512 512
```

### Option 3: Browser-based generator
```bash
npm run dev
# Open: http://localhost:5173/icon-generator.html
```

### Option 4: Online converters
- CloudConvert: https://cloudconvert.com/svg-to-png
- Convertio: https://convertio.co/svg-png/

---

## 📱 Platform-Specific Notes

### iOS (Safari)
- Uses `apple-touch-icon` (192×192)
- Automatically adds rounded corners
- Prefers solid background colors

### Android (Chrome)
- Supports adaptive/maskable icons
- `icon-512-maskable.png` has 80% safe zone
- Theme color: #00D9FF (Electric Blue)

### Desktop
- Uses `logo.svg` as favicon
- Scales cleanly at any size
- Theme color applied to browser chrome

---

## 🎨 Design Variations

### Sizes Available:
- **512×512**: Main app icon, splash screens
- **192×192**: Smaller screens, shortcuts
- **Maskable**: Android adaptive icon with safe zone

### Future Additions (if needed):
- 16×16, 32×32: Browser favicons
- 180×180: iOS-specific size
- 1024×1024: App store listings
- Splash screens: Various mobile sizes

---

## ✅ Design Checklist

- [x] Logo uses brand colors (Carbon Black, Gunmetal Gray, Electric Blue)
- [x] High contrast for visibility in bright conditions (garage lighting)
- [x] Recognizable at small sizes (48×48px)
- [x] Works on dark and light backgrounds
- [x] Professional, non-playful aesthetic
- [x] Automotive/mechanical theme
- [x] SVG and PNG versions available
- [x] Maskable/adaptive icon for Android
- [x] Proper safe zones for platform-specific cropping

---

**Created:** January 23, 2026  
**Tool Used:** SVG hand-coded with React component wrapper  
**License:** Proprietary - MOTO LENS Project
