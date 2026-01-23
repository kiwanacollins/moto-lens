import { createTheme } from '@mantine/core';
import type { MantineColorsTuple } from '@mantine/core';

// Brand color definitions
const carbonBlack: MantineColorsTuple = [
  '#C1C2C5', // lightest shade
  '#A6A7AB',
  '#909296',
  '#5C5F66',
  '#373A40',
  '#2C2E33',
  '#25262B',
  '#1A1B1E',
  '#141517',
  '#0A0A0A', // primary - Carbon Black
];

const gunmetalGray: MantineColorsTuple = [
  '#E7E9EA', // lightest shade
  '#CED1D3',
  '#B5B9BC',
  '#9CA1A5',
  '#83898E',
  '#6A7177',
  '#515960',
  '#384149',
  '#2C3539', // primary - Gunmetal Gray
  '#202A31',
];

const electricBlue: MantineColorsTuple = [
  '#E5F9FF', // lightest shade
  '#B8F1FF',
  '#8AEAFF',
  '#5CE2FF',
  '#2EDBFF',
  '#00D9FF', // primary - Electric Blue
  '#00ACD9',
  '#007FB3',
  '#00528C',
  '#002566',
];

export const theme = createTheme({
  colors: {
    carbonBlack,
    gunmetalGray,
    electricBlue,
  },
  primaryColor: 'electricBlue',
  primaryShade: 5,

  // Font settings
  fontFamily:
    'Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif',
  fontFamilyMonospace: 'JetBrains Mono, Monaco, Courier, monospace',
  headings: {
    fontFamily:
      'Inter, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Helvetica, Arial, sans-serif',
  },

  // Mobile-first responsive breakpoints
  breakpoints: {
    xs: '30em', // 480px
    sm: '48em', // 768px
    md: '64em', // 1024px
    lg: '74em', // 1184px
    xl: '90em', // 1440px
  },

  // Default colors for app
  defaultRadius: 'md',

  // Component default props
  components: {
    Button: {
      defaultProps: {
        size: 'lg', // Large buttons for glove-friendly usage
      },
    },
    TextInput: {
      defaultProps: {
        size: 'lg',
      },
    },
    PasswordInput: {
      defaultProps: {
        size: 'lg',
      },
    },
  },

  // Other theme settings
  other: {
    // Custom brand colors for easy access
    brandColors: {
      carbonBlack: '#0A0A0A',
      gunmetalGray: '#2C3539',
      electricBlue: '#00D9FF',
    },
  },
});

// Export color constants for direct use
export const BRAND_COLORS = {
  carbonBlack: '#0A0A0A',
  gunmetalGray: '#2C3539',
  electricBlue: '#00D9FF',
} as const;
