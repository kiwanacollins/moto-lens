# Copilot Instructions for MotoLens

Dont create quick summary documents or generic design guidelines. Instead, follow these detailed instructions to ensure all UI components, color schemes, typography, and visual styles align with the professional brand identity of MotoLens.:

## Project Overview

This is a professional **Progressive Web Application (PWA)** called **"MotoLens"** built with React 19, TypeScript, Vite, and Mantine UI. The app is designed for **garage mechanics and auto repair technicians** to decode VINs, visualize German vehicles (BMW, Audi, Mercedes-Benz, VW, Porsche), and identify parts interactively.

**Design Philosophy**: Clean, functional, mobile-first, professional—NOT generic AI-generated interfaces. Think **Stripe Dashboard meets Linear**—efficient, trustworthy, and polished.

### Current Development Phase

**IMPORTANT**: We are actively building and customizing the UI progressively. UI refinement happens continuously, not as a final step.

**Development Approach:**

1. **Build new features with professional design from the start** - No AI slop patterns
2. **Customize existing UI components as we encounter them** - Fix AI slop patterns when working in those areas
3. **Apply Mantine components and anti-AI-slop principles to ALL work** - New and existing code
4. **Progressive refinement** - We improve the UI as we go, not waiting until the end

**What this means for you:**

**When creating NEW components:**
- ✅ Follow all professional design patterns strictly
- ✅ Use Mantine components as foundation
- ✅ Apply proper color contrast, spacing, and interactions
- ✅ NO AI slop patterns from the start

**When modifying EXISTING components:**
- ✅ Refactor AI slop patterns you encounter (left borders, pastel badges, emoji icons, etc.)
- ✅ Replace custom divs with Mantine card/paper components
- ✅ Fix low-contrast icon/background combinations
- ✅ Use react-icons instead of emojis
- ✅ Apply professional styling while maintaining functionality

**When in doubt:**
- Always choose the professional, non-generic approach
- Refactor AI slop when you see it
- Use Mantine components over custom divs
- Ask before making breaking changes to existing functionality

---

## Core Design Philosophy

### Theme: Professional Mobile-First PWA

- **Mobile-first responsive design**: Optimize for mechanics using phones/tablets in garages
- **Clean and functional**: Prioritize usability and clarity over decoration
- **Business-focused aesthetic**: Think Stripe, Linear, Vercel—not flashy, but polished
- **Automotive industry professionalism**: Trustworthy interface for professionals
- **Fast and efficient**: Mechanics need quick access to information
- **NO purple-blue gradients**: Avoid typical AI-generated color schemes
- **NO generic glassmorphism**: Use solid backgrounds with subtle depth
- **NO left-border accent bars on cards**: This is the most overused AI pattern
- **NO uniform spacing everywhere**: Vary spacing intentionally for hierarchy

### Component Library: Mantine UI (Customized)

**Primary Component Library:**
- **Mantine UI** as the foundation for all UI components
- **NEVER use Mantine components straight out of the box**
- Customize colors, spacing, and styles to match brand identity
- Override default Mantine theme with custom configuration
- Supplement with custom components when Mantine doesn't fit

**Secondary Components:**
- **react-icons** for ALL icons (MANDATORY - see icon section below)
- Custom components for automotive-specific features (VIN decoder, 360° viewer, part selector)

**Key Principle**: Mantine provides the foundation, but every component should be customized to avoid the "template" look.

---

## Color Palette: Professional & Automotive

**PRIMARY BRAND COLORS:**

**Core Brand Identity:**
- **Electric Blue**: `#0ea5e9` (sky-500) - Primary actions, CTAs, interactive elements, highlights
- **Carbon Black**: `#0a0a0a` - Main text, headings, high-contrast elements
- **Gunmetal Gray**: `#52525b` (zinc-600) - Secondary text, icons, subtle elements

**These are your MAIN colors. Use them prominently and consistently.**

**Supporting Neutrals:**
- **Zinc 50**: `#fafafa` - Light backgrounds, subtle sections
- **Zinc 100**: `#f4f4f5` - Hover states, muted backgrounds
- **Zinc 200**: `#e4e4e7` - Borders, dividers
- **Zinc 300**: `#d4d4d8` - Disabled states, subtle borders
- **Zinc 700**: `#3f3f46` - Dark text, dark mode elements
- **Zinc 800**: `#27272a` - Dark backgrounds
- **Zinc 900**: `#18181b` - Deepest dark backgrounds
- **Pure White**: `#ffffff` - Cards, light mode base

**Semantic Colors (Use Sparingly):**
- **Success**: `#10b981` (emerald-500) - Success states, confirmations
- **Warning**: `#f59e0b` (amber-500) - Warnings, caution states
- **Error/Destructive**: `#ef4444` (red-500) - Errors, destructive actions
- **Info**: `#0ea5e9` (Electric Blue) - Informational messages, use primary

**Automotive-Specific Colors:**
- **Engine/Mechanical**: Use zinc/gunmetal tones for mechanical parts
- **Electrical**: Use electric blue for electrical components
- **Body/Exterior**: Use electric blue highlights for body panels
- **Interior**: Use neutral zinc tones for interior components

**Why This Palette Works:**
- ✅ **Premium aesthetic**: Carbon black + electric blue = modern, high-end feel
- ✅ **High contrast**: Excellent readability in bright garage environments
- ✅ **Professional**: Gunmetal gray provides sophisticated middle ground
- ✅ **Scalable**: Works beautifully from mobile to desktop
- ✅ **Automotive**: Evokes performance, precision, technology

**Color Usage Guidelines:**

**Electric Blue (#0ea5e9):**
- ✅ Primary buttons and CTAs
- ✅ Active navigation items
- ✅ Links and interactive elements
- ✅ Brand accent throughout the UI
- ✅ Important badges/labels
- ✅ Part highlights on car visualization
- ✅ Interactive hover states
- ✅ Focus rings and active states
- ❌ DO NOT overuse - use as accent, not everywhere

**Carbon Black (#0a0a0a):**
- ✅ Main headings (h1, h2, h3)
- ✅ Body text in light mode
- ✅ High-contrast UI elements
- ✅ VIN numbers, part codes (with JetBrains Mono)
- ✅ Technical data and specifications
- ✅ Dark backgrounds (light mode cards can use this as bg with white text)
- ❌ DO NOT use as page background in light mode (too harsh)

**Gunmetal Gray (#52525b):**
- ✅ Secondary text and descriptions
- ✅ Icons in neutral states
- ✅ Subtle UI elements
- ✅ Placeholder text
- ✅ Disabled state text (at 50% opacity)
- ✅ Metadata and timestamps

**White (#ffffff):**
- ✅ Page backgrounds in light mode
- ✅ Card backgrounds
- ✅ Text on carbon black/dark backgrounds
- ✅ Button text on electric blue primary buttons

**DO NOT:**
- ❌ Create random purple/pink/red gradients
- ❌ Use neon colors or overly saturated hues outside electric blue
- ❌ Use more than 2-3 colors in a single component
- ❌ Mix multiple bright accent colors (electric blue is your only accent)

**Mantine Theme Configuration:**

```typescript
import { MantineProvider, createTheme } from '@mantine/core';

const theme = createTheme({
  primaryColor: 'blue',
  colors: {
    blue: [
      '#e0f2fe', // sky-100
      '#bae6fd', // sky-200
      '#7dd3fc', // sky-300
      '#38bdf8', // sky-400
      '#0ea5e9', // Electric Blue (index 4) - Primary
      '#0284c7', // sky-600
      '#0369a1', // sky-700
      '#075985', // sky-800
      '#0c4a6e', // sky-900
      '#082f49', // sky-950
    ],
    dark: [
      '#fafafa', // zinc-50
      '#f4f4f5', // zinc-100
      '#e4e4e7', // zinc-200
      '#d4d4d8', // zinc-300
      '#a1a1aa', // zinc-400
      '#71717a', // zinc-500
      '#52525b', // Gunmetal Gray (index 6)
      '#3f3f46', // zinc-700
      '#27272a', // zinc-800
      '#0a0a0a', // Carbon Black (index 9)
    ],
  },
  fontFamily: 'Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, sans-serif',
  fontFamilyMonospace: 'JetBrains Mono, Fira Code, Consolas, Monaco, Courier New, monospace',
  headings: {
    fontFamily: 'Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif',
    fontWeight: '600',
  },
  defaultRadius: 'md',
  spacing: {
    xs: '0.5rem',
    sm: '0.75rem',
    md: '1rem',
    lg: '1.5rem',
    xl: '2rem',
  },
});

export default theme;
```

---

## Typography: Clean & Readable

**Font Stack:**
- **Primary**: **Inter** - Clean, modern, highly legible for UI text, headings, body copy
- **Monospace**: **JetBrains Mono** - Technical data, VIN numbers, part codes, measurements
- **Fallback**: System font stack for performance

**Why These Fonts:**
- ✅ **Inter**: Industry-standard, excellent readability at all sizes, professional
- ✅ **JetBrains Mono**: Superior monospace font, clear character distinction (0 vs O, 1 vs I vs l)
- ✅ **Performance**: Both are optimized web fonts with variable font support
- ✅ **Garage-ready**: High legibility in bright outdoor/garage lighting

**Typography Rules:**
- **Heading hierarchy**: Use 5-6 distinct sizes maximum
- **Line height**: 1.6-1.7 for body text (not default 1.5)
- **Letter spacing**: `tracking-tight` (-0.02em) for large headings
- **Font weights**: 
  - 600 (semibold) for headings
  - 400 (regular) for body text
  - 500 (medium) for emphasis/labels
  - 700 (bold) for extra emphasis (use sparingly)
- **Text width**: Use `max-w-[65ch]` for long-form content
- **Technical data**: ALWAYS use JetBrains Mono with `tabular-nums` for VIN, part numbers, measurements

**Font Usage Examples:**
```tsx
// ✅ GOOD: Inter for UI text
<Text ff="Inter" fw={600} size="xl">Vehicle Information</Text>
<Text ff="Inter" size="sm" c="dimmed">Last scanned 2 hours ago</Text>

// ✅ GOOD: JetBrains Mono for VIN
<Text ff="JetBrains Mono" fw={500} size="lg" c="dark.9">
  WBADT63452CZ12345
</Text>

// ✅ GOOD: JetBrains Mono for part numbers
<Code ff="JetBrains Mono">11-42-7-566-327</Code>

// ✅ GOOD: Using Mantine props
<Title order={1} ff="Inter">MotoLens</Title>
<Text ff="mono">VIN: WBADT63452CZ12345</Text>
```

**Mobile-Specific Typography:**
- Slightly larger base font size on mobile (16px minimum to prevent zoom)
- Readable text even in bright garage environments
- High contrast for outdoor visibility
- Inter's taller x-height improves mobile readability

**What to AVOID:**
- ❌ Don't use multiple font families beyond Inter + JetBrains Mono
- ❌ Don't use ultra-thin weights (100-200) for important text
- ❌ Don't make everything bold
- ❌ Don't use all-caps extensively (except VIN, part codes)
- ❌ Don't use Comic Sans, cursive, or decorative fonts (obvious but worth stating)

---

## Visual Style & Design Patterns

### Card Design (CRITICAL - Avoid AI Slop)

**ALWAYS use Mantine Paper/Card components as the foundation. DO NOT create custom card divs with thin borders.**

**❌ DO NOT (AI Slop Pattern):**
- ❌ Create custom card divs with thin borders matching background color
- ❌ Use `border border-green-500` on a green background card
- ❌ Add left border accent bars (`border-l-4 border-blue-500`)
- ❌ Use colored left strips on cards
- ❌ Add random drop shadows everywhere
- ❌ Make all cards perfectly rounded
- ❌ Use custom divs when Mantine components exist

**✅ DO (Professional Pattern):**
- ✅ **Use Mantine `Paper` or `Card` component** as default
- ✅ Use Mantine's built-in variants: `shadow="sm"`, `shadow="md"`, `withBorder`
- ✅ Customize with additional styles when needed
- ✅ Create visual hierarchy through spacing, not decoration

**✅ CORRECT: Using Mantine components with MotoLens theme**

```tsx
import { Paper, Card, Group, Text, Badge, Image } from '@mantine/core';

// ✅ GOOD: Mantine Paper for simple card
<Paper shadow="sm" p="md" radius="md" withBorder>
  <Text fw={600} size="lg" c="dark.9" ff="Inter">VIN Decoder</Text>
  <Text size="sm" c="dark.6" ff="Inter">Decode vehicle information</Text>
</Paper>

// ✅ GOOD: Mantine Card with sections
<Card shadow="md" padding="lg" radius="md" withBorder>
  <Card.Section>
    <Image src="/bmw-3-series.jpg" height={160} alt="BMW 3 Series" />
  </Card.Section>
  
  <Group justify="space-between" mt="md" mb="xs">
    <Text fw={600} c="dark.9" ff="Inter">BMW 3 Series</Text>
    <Badge color="blue.4" variant="filled">2020</Badge>
  </Group>
  
  <Text size="sm" c="dark.6" ff="JetBrains Mono" fw={500}>
    VIN: WBADT63452CZ12345
  </Text>
</Card>

// ✅ GOOD: Stat card using Paper with electric blue accent
<Paper shadow="xs" p="md" radius="md" withBorder style={{ borderTop: '3px solid #0ea5e9' }}>
  <Group>
    <div>
      <Text size="xs" c="dark.6" tt="uppercase" fw={700} ff="Inter">Parts Scanned</Text>
      <Text fw={700} size="xl" c="dark.9" ff="Inter">1,234</Text>
    </div>
  </Group>
</Paper>

// ✅ GOOD: Dark card with white text
<Paper bg="dark.9" p="lg" radius="md">
  <Text c="white" fw={600} size="lg" ff="Inter">Vehicle Details</Text>
  <Text c="zinc.3" size="sm" ff="Inter">Complete technical specifications</Text>
</Paper>
```

**Mantine Component Reference:**
- `Paper` - Base container with elevation
- `Card` - Paper with additional sections and structure
- `Card.Section` - Full-width sections within card
- Props: `shadow`, `padding`, `radius`, `withBorder`
- Combine with Mantine's spacing and color utilities

**Layout Patterns:**
- **Mobile-first grid**: Use Mantine `Grid` and `SimpleGrid` for responsive layouts
- **Stack components**: Use Mantine `Stack` for vertical layouts
- **Group components**: Use Mantine `Group` for horizontal layouts
- **Responsive spacing**: Use Mantine's responsive props (`p={{ base: 'sm', md: 'lg' }}`)

**Backgrounds:**
- **Primary background**: White in light mode, dark in dark mode
- **Secondary background**: Mantine gray shades
- **NO gradients** unless for data visualization (charts only)

---

## Icon Library & Usage (CRITICAL - MUST USE REACT-ICONS)

**MANDATORY: You MUST use `react-icons` for ALL icons. This is NOT negotiable.**

- ✅ **ONLY use `react-icons` for ALL icons** - This is the REQUIRED icon library
- ✅ Import from specific icon sets within react-icons:
  - **Material Design Icons**: `import { MdDirectionsCar, MdBuild } from 'react-icons/md'`
  - **Feather Icons**: `import { FiSettings, FiSearch } from 'react-icons/fi'`
  - **Bootstrap Icons**: `import { BsGearFill, BsSpeedometer2 } from 'react-icons/bs'`
  - **Ionicons**: `import { IoCarSport, IoSpeedometer } from 'react-icons/io5'`
- ✅ Consistent sizing: Use Mantine's size system or explicit sizes
- ❌ **NEVER use emojis** (🚗, 🔧, ⚙️, etc.) - Unprofessional and inconsistent
- ❌ **NEVER use text-based icons** or Unicode symbols
- ❌ **DO NOT use lucide-react** - We use react-icons

**Why react-icons:**
- ✅ Comprehensive icon sets (Material, Feather, Bootstrap, Hero, Font Awesome, etc.)
- ✅ Consistent API across all icon sets
- ✅ Tree-shakable - only imports icons you use
- ✅ Works seamlessly with Mantine and Tailwind

**Automotive-Specific Icons:**
```tsx
// ✅ GOOD: Using automotive-related react-icons with MotoLens theme
import { 
  MdDirectionsCar, 
  MdBuild, 
  MdSettings,
  MdSpeed,
  MdLocalGasStation,
  MdCarRepair 
} from 'react-icons/md';
import { IoCarSport, IoSpeedometer } from 'react-icons/io5';
import { BsGearFill, BsSpeedometer2 } from 'react-icons/bs';
import { FiTool, FiSettings, FiScan } from 'react-icons/fi';

// With electric blue primary color
<MdDirectionsCar size={24} style={{ color: '#0ea5e9' }} />
<FiTool size={20} style={{ color: '#52525b' }} />
<BsGearFill className="w-5 h-5" style={{ color: '#0a0a0a' }} />
<FiScan size={24} style={{ color: '#0ea5e9' }} />

// Using with Mantine components
import { ThemeIcon } from '@mantine/core';

<ThemeIcon color="blue.4" size="lg" radius="md">
  <MdDirectionsCar size={20} />
</ThemeIcon>

<ThemeIcon color="dark.9" size="md" radius="md" variant="light">
  <FiTool size={18} />
</ThemeIcon>
```

**Icon & Background Color Rules:**
- ✅ **High contrast is mandatory**: Icon and background must have sufficient contrast
- ✅ Use neutral backgrounds for icon containers
- ✅ Colored icons on neutral backgrounds
- ✅ White/light icons on colored backgrounds
- ❌ **NEVER** match icon color to background color

---

## Status Badges & Labels (CRITICAL - Avoid AI Slop)

**The pastel badge pattern is AI slop. Use professional badge designs.**

**❌ NEVER do this (AI slop pattern):**
```tsx
// ❌ BAD: Pastel background with matching text (low contrast)
<span className="bg-green-100 text-green-600 px-3 py-1 rounded-full">Available</span>
```

**✅ Professional badge patterns using Mantine:**

```tsx
import { Badge } from '@mantine/core';

// ✅ GOOD: Solid Mantine badges with theme colors
<Badge color="green" variant="filled">Available</Badge>
<Badge color="blue.4" variant="filled">In Stock</Badge>
<Badge color="red" variant="filled">Out of Stock</Badge>
<Badge color="yellow" variant="filled">Low Stock</Badge>

// ✅ GOOD: Variant styles with electric blue
<Badge variant="filled" color="blue.4">OEM Part</Badge>
<Badge variant="outline" color="blue.4">Compatible</Badge>
<Badge variant="dot" color="blue.4">Active</Badge>

// ✅ GOOD: Status badges with semantic colors
<Badge color="green" variant="light">Verified VIN</Badge>
<Badge color="red" variant="light">Invalid VIN</Badge>
<Badge color="blue.4" variant="filled" ff="Inter">BMW Genuine</Badge>

// ✅ GOOD: Dark badge with white text
<Badge bg="dark.9" c="white" ff="Inter" fw={500}>Premium</Badge>
```

**Badge Design Rules:**
- ✅ Use Mantine `Badge` component with semantic colors
- ✅ Use `variant="filled"` for high emphasis
- ✅ Use `variant="outline"` for medium emphasis
- ✅ Use `variant="dot"` for subtle indicators
- ✅ Ensure WCAG AA contrast ratio (4.5:1 minimum)
- ❌ **NEVER** use pastel backgrounds with matching text
- ❌ **NEVER** use custom badge divs when Mantine Badge exists

---

## Motion & Animations

**Mantine Animation System:**
- Use Mantine's built-in transitions
- Respect `prefers-reduced-motion`
- Keep animations subtle and functional

**Animation Guidelines:**
- **Timing**: 150-300ms for UI transitions
- **Easing**: Use `ease-out` for entering, `ease-in` for exiting
- **Mobile performance**: Animate `transform` and `opacity` only

**When to Animate:**
- Button interactions: Subtle scale on press
- Modal/drawer entrance: Slide animations
- Loading states: Skeleton screens (NOT spinners)
- Part highlighting: Smooth color transitions

**What to AVOID:**
- ❌ Animations on page load
- ❌ Slow animations (>500ms)
- ❌ Excessive bounce effects
- ❌ Random fade-ins on scroll

---

## Mobile-First & PWA Considerations

**Critical for MotoLens (garage environment):**

**Touch Targets:**
- Minimum 44x44px for all interactive elements
- Larger tap areas for primary actions (48x48px+)
- Adequate spacing between interactive elements

**Performance:**
- Lazy load heavy components (360° viewer, image galleries)
- Optimize images with proper compression
- Use service workers for offline functionality
- Cache VIN decoder data locally

**Accessibility:**
- High contrast for bright garage environments
- Large, readable text (16px minimum)
- Glove-friendly interface (larger buttons)
- Voice input support for VIN entry (future)

**PWA Features:**
- Install prompt for "Add to Home Screen"
- Offline mode with cached data
- Fast loading (< 3 seconds on 3G)
- Splash screen with MotoLens branding

---

## Automotive-Specific Features

### VIN Decoder Interface
- Large input field for VIN entry (17 characters)
- Barcode scanner integration (camera API)
- Real-time validation as user types
- Clear error states for invalid VINs
- Display decoded vehicle information clearly

### 360° Vehicle Viewer
- Touch/swipe gestures for rotation
- Pinch-to-zoom functionality
- Tap parts to highlight and identify
- Smooth animations (60fps)
- Part labels on hover/tap

### Part Information Display
- Part name and OEM number
- Compatible aftermarket parts
- Estimated pricing (if available)
- Installation complexity indicator
- Related parts suggestions

### Search & Filtering
- Search by part name or number
- Filter by vehicle system (engine, transmission, electrical, body)
- Filter by German brand (BMW, Audi, Mercedes, VW, Porsche)
- Recent searches saved locally

---

## Code Quality & Architecture

**React 19 + TypeScript Best Practices:**
- Use functional components with hooks
- TypeScript strict mode enabled
- No `any` types (use `unknown` if needed)
- Proper prop typing with interfaces
- Use Zod for runtime validation

**File Organization:**
```
src/
  components/
    VinDecoder/
      VinDecoder.tsx
      VinInput.tsx
      VinResult.tsx
    Vehicle360Viewer/
      Vehicle360Viewer.tsx
      PartSelector.tsx
    PartInfo/
      PartDetails.tsx
      PartsList.tsx
  hooks/
    useVinDecoder.ts
    usePartSearch.ts
  services/
    vinApi.ts
    partsApi.ts
  types/
    vehicle.ts
    part.ts
  utils/
    vinValidator.ts
    formatters.ts
```

**State Management:**
- React hooks for local state
- Context API for shared state (theme, user preferences)
- Consider Zustand or Jotai for complex state (lightweight alternatives to Redux)

**Performance:**
- Lazy load heavy components
- Memoize expensive calculations
- Debounce search inputs
- Optimize images and assets

---

## What to ABSOLUTELY AVOID

**Visual Anti-Patterns:**
- ❌ Purple-blue gradient backgrounds
- ❌ Left-border accent bars on cards
- ❌ Glassmorphism blur effects everywhere
- ❌ Neon glows or shadows
- ❌ Uniform spacing (p-4 on everything)
- ❌ Generic fade-in animations
- ❌ **Icon background matching icon color (low contrast)**
- ❌ Emoji icons (🚗, 🔧, ⚙️)
- ❌ Pastel badges with matching text color

**Code Anti-Patterns:**
- ❌ Using `any` type in TypeScript
- ❌ Inline styles instead of Mantine/Tailwind utilities
- ❌ Hardcoded values instead of theme variables
- ❌ Not handling loading/error states
- ❌ Creating custom components when Mantine equivalents exist

**UX Anti-Patterns:**
- ❌ No confirmation on destructive actions
- ❌ Generic error messages ("Something went wrong")
- ❌ Disabled buttons with no explanation
- ❌ Forms that clear on error
- ❌ No loading states during API calls

---

## Task List Management

### Task Implementation Protocol

- **One sub-task at a time**: Do NOT start the next sub-task until you ask the user for permission
- **Completion protocol:**
  1. When you finish a **sub-task**, mark it as completed `[✓]`
  2. If **all** subtasks underneath a parent task are `[✓]`, mark the **parent task** as completed `[✓]`
- Stop after each sub-task and wait for user's go-ahead

### After Task Completion

- **DO NOT create separate documentation files** to summarize work
- **DO NOT generate markdown files** like "IMPLEMENTATION_SUMMARY.md"
- All progress tracking happens in TASKS.md only
- Provide brief verbal summary of changes
- Ask "Ready to proceed?" and wait for confirmation

**CRITICAL:** After finishing any task:
- ✅ Give brief summary in chat
- ✅ Update TASKS.md (if exists)
- ✅ Ask permission to continue
- ❌ DO NOT create new .md documentation files
- ❌ DO NOT generate implementation summaries

---

## Remember

This is a **professional tool for automotive mechanics**. Every design decision should prioritize:

1. **Clarity**: Mechanics need to find parts quickly in noisy garage environments
2. **Efficiency**: Fast workflows for common tasks (VIN decode → part ID → info)
3. **Reliability**: The interface must be trustworthy and accurate
4. **Mobile-first**: Designed for phones/tablets, not desktop
5. **Professional**: Represents the mechanic's expertise and professionalism

**Avoid generic AI aesthetics. Create something mechanics will trust and rely on daily.**

---

## Design Inspiration

Study these products for design reference:
- **Stripe Dashboard** - Clean data display
- **Linear** - Efficient task management UI
- **Vercel** - Professional developer tools
- **Notion** - Intuitive information architecture

**NOT these:**
- Generic SaaS templates
- Colorful dashboard themes
- Overly decorated interfaces
- AI-generated landing pages

---

## Final Principles

**Constraint Creates Quality:**
- 3 core colors: Electric Blue (#0ea5e9), Carbon Black (#0a0a0a), Gunmetal Gray (#52525b)
- 2 fonts: Inter (UI), JetBrains Mono (technical data)
- 5-6 font sizes maximum
- 2-3 animation patterns maximum
- One button style per purpose

**Polish is in the Details:**
- Consistent spacing throughout
- Proper loading and error states
- Thoughtful empty states
- Helpful validation messages
- Smooth transitions between states
- JetBrains Mono for ALL VINs and part numbers

**Professional, Not Flashy:**
- This is a professional tool, not a marketing page
- Mechanics want efficiency, not decoration
- Every element should serve a purpose
- Form follows function
- Carbon black + electric blue = premium, trustworthy

**Mobile-First Always:**
- Design for thumbs, not mouse pointers
- Large touch targets
- Readable in bright garage environments
- Fast loading on mobile networks
- High contrast (carbon black on white, white on carbon black)
