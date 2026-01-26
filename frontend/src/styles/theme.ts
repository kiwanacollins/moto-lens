import { createTheme } from '@mantine/core';
import type { MantineColorsTuple } from '@mantine/core';

/**
 * MotoLens Design System - Professional Mobile-First PWA Theme
 * 
 * Core Brand Colors:
 * - Electric Blue (#0ea5e9) - Primary actions, CTAs, interactive elements
 * - Carbon Black (#0a0a0a) - Main text, headings, high-contrast elements
 * - Gunmetal Gray (#52525b) - Secondary text, icons, subtle elements
 * 
 * Design Philosophy: Clean, functional, professional
 * Think: Stripe Dashboard meets Linear
 */

// PRIMARY BRAND COLOR: Electric Blue (sky-500 based)
const electricBlue: MantineColorsTuple = [
  '#e0f2fe', // sky-100
  '#bae6fd', // sky-200
  '#7dd3fc', // sky-300
  '#38bdf8', // sky-400
  '#0ea5e9', // sky-500 - PRIMARY Electric Blue
  '#0284c7', // sky-600
  '#0369a1', // sky-700
  '#075985', // sky-800
  '#0c4a6e', // sky-900
  '#082f49', // sky-950
];

// SUPPORTING NEUTRALS: Zinc palette (replaces old gunmetalGray and carbonBlack)
const zinc: MantineColorsTuple = [
  '#fafafa', // zinc-50 - Light backgrounds
  '#f4f4f5', // zinc-100 - Hover states, muted backgrounds
  '#e4e4e7', // zinc-200 - Borders, dividers
  '#d4d4d8', // zinc-300 - Disabled states
  '#a1a1aa', // zinc-400
  '#71717a', // zinc-500
  '#52525b', // zinc-600 - Gunmetal Gray (secondary text, icons)
  '#3f3f46', // zinc-700 - Dark text, dark mode elements
  '#27272a', // zinc-800 - Dark backgrounds
  '#0a0a0a', // zinc-900 - Carbon Black (main text, deepest dark)
];

// SEMANTIC COLORS (Use Sparingly)
const success: MantineColorsTuple = [
  '#d1fae5',
  '#a7f3d0',
  '#6ee7b7',
  '#34d399',
  '#10b981', // emerald-500 - Primary success
  '#059669',
  '#047857',
  '#065f46',
  '#064e3b',
  '#022c22',
];

const warning: MantineColorsTuple = [
  '#fef3c7',
  '#fde68a',
  '#fcd34d',
  '#fbbf24',
  '#f59e0b', // amber-500 - Primary warning
  '#d97706',
  '#b45309',
  '#92400e',
  '#78350f',
  '#451a03',
];

const error: MantineColorsTuple = [
  '#fee2e2',
  '#fecaca',
  '#fca5a5',
  '#f87171',
  '#ef4444', // red-500 - Primary error
  '#dc2626',
  '#b91c1c',
  '#991b1b',
  '#7f1d1d',
  '#450a0a',
];

export const theme = createTheme({
  // Color Palette (Light mode defaults set in MantineProvider)
  colors: {
    // Primary brand color (Electric Blue)
    blue: electricBlue,

    // Neutrals (Carbon Black + Gunmetal Gray + full zinc scale)
    dark: zinc,
    gray: zinc,

    // Semantic colors
    green: success,
    yellow: warning,
    red: error,

    // Aliases for backwards compatibility and clarity
    electricBlue: electricBlue,
  },

  primaryColor: 'blue',
  primaryShade: 4, // Index 4 = #0ea5e9 (Electric Blue)

  // Light mode: white background, dark text
  white: '#ffffff',
  black: '#0a0a0a',

  // Typography
  fontFamily:
    'Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica Neue, sans-serif',
  fontFamilyMonospace:
    'JetBrains Mono, Fira Code, Consolas, Monaco, Courier New, monospace',

  headings: {
    fontFamily:
      'Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif',
    fontWeight: '600',
    sizes: {
      h1: { fontSize: '2.5rem', lineHeight: '1.2' },
      h2: { fontSize: '2rem', lineHeight: '1.3' },
      h3: { fontSize: '1.5rem', lineHeight: '1.4' },
      h4: { fontSize: '1.25rem', lineHeight: '1.5' },
      h5: { fontSize: '1.125rem', lineHeight: '1.5' },
      h6: { fontSize: '1rem', lineHeight: '1.6' },
    },
  },

  // Line height for body text (improved readability)
  lineHeights: {
    xs: '1.4',
    sm: '1.5',
    md: '1.6',
    lg: '1.7',
    xl: '1.8',
  },

  // Spacing (intentionally varied for hierarchy)
  spacing: {
    xs: '0.5rem',   // 8px
    sm: '0.75rem',  // 12px
    md: '1rem',     // 16px
    lg: '1.5rem',   // 24px
    xl: '2rem',     // 32px
  },

  // Border Radius
  defaultRadius: 'md',
  radius: {
    xs: '0.25rem',  // 4px
    sm: '0.375rem', // 6px
    md: '0.5rem',   // 8px
    lg: '0.75rem',  // 12px
    xl: '1rem',     // 16px
  },

  // Mobile-first responsive breakpoints
  breakpoints: {
    xs: '30em',  // 480px
    sm: '48em',  // 768px
    md: '64em',  // 1024px
    lg: '74em',  // 1184px
    xl: '90em',  // 1440px
  },

  // Shadows (subtle, professional)
  shadows: {
    xs: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
    sm: '0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)',
    md: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
    lg: '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
    xl: '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)',
  },

  // Component Default Props (Mobile-first, glove-friendly, light mode)
  components: {
    Button: {
      defaultProps: {
        size: 'lg', // Large buttons for garage/glove usage (min 44x44px)
      },
      styles: {
        root: {
          fontWeight: 500,
        },
      },
    },

    TextInput: {
      defaultProps: {
        size: 'lg', // Large for easy tapping
      },
      styles: {
        input: {
          backgroundColor: '#ffffff',
          borderColor: '#e4e4e7',
          color: '#0a0a0a',
          '&::placeholder': {
            color: '#71717a',
          },
        },
        label: {
          color: '#0a0a0a',
        },
      },
    },

    PasswordInput: {
      defaultProps: {
        size: 'lg',
      },
      styles: {
        input: {
          backgroundColor: '#ffffff',
          borderColor: '#e4e4e7',
          color: '#0a0a0a',
        },
        innerInput: {
          color: '#0a0a0a',
          '&::placeholder': {
            color: '#71717a',
          },
        },
        label: {
          color: '#0a0a0a',
        },
      },
    },

    Paper: {
      defaultProps: {
        shadow: 'sm',
        radius: 'md',
      },
      styles: {
        root: {
          backgroundColor: '#ffffff',
        },
      },
    },

    Card: {
      defaultProps: {
        shadow: 'sm',
        radius: 'md',
      },
      styles: {
        root: {
          backgroundColor: '#ffffff',
        },
      },
    },

    Badge: {
      defaultProps: {
        variant: 'filled',
        radius: 'sm',
      },
    },

    Modal: {
      defaultProps: {
        centered: true,
        radius: 'md',
      },
      styles: {
        content: {
          backgroundColor: '#ffffff',
        },
        header: {
          backgroundColor: '#ffffff',
        },
        title: {
          color: '#0a0a0a',
        },
      },
    },

    Code: {
      defaultProps: {
        ff: 'JetBrains Mono, monospace',
      },
    },

    Text: {
      styles: {
        root: {
          color: '#0a0a0a',
        },
      },
    },

    Title: {
      styles: {
        root: {
          color: '#0a0a0a',
        },
      },
    },

    Anchor: {
      styles: {
        root: {
          color: '#0ea5e9',
        },
      },
    },
  },

  // Custom theme properties
  other: {
    // Brand font for handwritten headings
    fontFamilyBrand: 'Caveat, cursive',

    // Direct color access for convenience
    brandColors: {
      electricBlue: '#0ea5e9',    // Primary - Actions, CTAs, highlights
      carbonBlack: '#0a0a0a',     // Main text, headings
      gunmetalGray: '#52525b',    // Secondary text, icons
      white: '#ffffff',           // Light backgrounds, text on dark
    },

    // Semantic colors
    semanticColors: {
      success: '#10b981',         // emerald-500
      warning: '#f59e0b',         // amber-500
      error: '#ef4444',           // red-500
      info: '#0ea5e9',            // Electric Blue (reuse primary)
    },

    // Zinc neutrals for easy reference
    neutrals: {
      zinc50: '#fafafa',
      zinc100: '#f4f4f5',
      zinc200: '#e4e4e7',
      zinc300: '#d4d4d8',
      zinc400: '#a1a1aa',
      zinc500: '#71717a',
      zinc600: '#52525b',
      zinc700: '#3f3f46',
      zinc800: '#27272a',
      zinc900: '#0a0a0a',
    },

    // Animation timing
    transitions: {
      fast: '150ms',
      base: '200ms',
      slow: '300ms',
    },

    // Touch targets (minimum sizes for mobile)
    touchTargets: {
      minimum: '44px',
      comfortable: '48px',
      large: '56px',
    },
  },
});

// ============================================================================
// EXPORTED CONSTANTS FOR DIRECT USE
// ============================================================================

/**
 * Primary Brand Colors
 * Use these for consistency throughout the app
 */
export const BRAND_COLORS = {
  electricBlue: '#0ea5e9',
  carbonBlack: '#0a0a0a',
  gunmetalGray: '#52525b',
  white: '#ffffff',
} as const;

/**
 * Semantic Colors
 */
export const SEMANTIC_COLORS = {
  success: '#10b981',
  warning: '#f59e0b',
  error: '#ef4444',
  info: '#0ea5e9',
} as const;

/**
 * Zinc Neutral Scale
 */
export const NEUTRALS = {
  zinc50: '#fafafa',
  zinc100: '#f4f4f5',
  zinc200: '#e4e4e7',
  zinc300: '#d4d4d8',
  zinc400: '#a1a1aa',
  zinc500: '#71717a',
  zinc600: '#52525b',  // Gunmetal Gray
  zinc700: '#3f3f46',
  zinc800: '#27272a',
  zinc900: '#0a0a0a',  // Carbon Black
} as const;

/**
 * Typography Constants
 */
export const TYPOGRAPHY = {
  fontFamily: 'Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif',
  fontMono: 'JetBrains Mono, Fira Code, Consolas, Monaco, monospace',
  fontBrand: 'Caveat, cursive',

  fontWeights: {
    regular: 400,
    medium: 500,
    semibold: 600,
    bold: 700,
  },

  lineHeights: {
    tight: 1.2,
    normal: 1.5,
    relaxed: 1.6,
    loose: 1.7,
  },
} as const;

/**
 * Spacing Scale
 */
export const SPACING = {
  xs: '0.5rem',   // 8px
  sm: '0.75rem',  // 12px
  md: '1rem',     // 16px
  lg: '1.5rem',   // 24px
  xl: '2rem',     // 32px
  '2xl': '2.5rem', // 40px
  '3xl': '3rem',   // 48px
} as const;

/**
 * Animation Timing
 */
export const TRANSITIONS = {
  fast: '150ms ease-out',
  base: '200ms ease-out',
  slow: '300ms ease-out',
} as const;

/**
 * Touch Target Sizes (Mobile-First)
 */
export const TOUCH_TARGETS = {
  minimum: 44,      // 44px - iOS minimum
  comfortable: 48,  // 48px - Recommended
  large: 56,        // 56px - Extra comfortable
} as const;

/**
 * Breakpoints (in pixels)
 */
export const BREAKPOINTS = {
  xs: 480,
  sm: 768,
  md: 1024,
  lg: 1184,
  xl: 1440,
} as const;

/**
 * Style Utilities
 * Helper functions for common styling patterns
 */
export const styleUtils = {
  // Add electric blue focus ring
  focusRing: {
    outline: `2px solid ${BRAND_COLORS.electricBlue}`,
    outlineOffset: '2px',
  },

  // High contrast text for garage environments
  highContrastText: {
    color: BRAND_COLORS.carbonBlack,
    textShadow: '0 1px 2px rgba(0, 0, 0, 0.1)',
  },

  // Professional card styling (Mantine Paper/Card base)
  card: {
    background: BRAND_COLORS.white,
    borderRadius: '0.5rem',
    boxShadow: '0 1px 3px 0 rgb(0 0 0 / 0.1)',
  },

  // Monospace text for technical data
  monoText: {
    fontFamily: TYPOGRAPHY.fontMono,
    fontVariantNumeric: 'tabular-nums',
  },
} as const;
