# Styling Guidelines

### Styling Approach

```typescript
// Example of a styled button component
import React from 'react';

interface ButtonProps {
  children: React.ReactNode;
  primary?: boolean;
  onClick?: () => void;
}

const Button: React.FC<ButtonProps> = ({ children, primary = false, onClick }) => {
  const baseStyles = "px-4 py-2 rounded-md font-semibold transition-colors duration-200";
  const primaryStyles = "bg-blue-600 text-white hover:bg-blue-700";
  const secondaryStyles = "bg-gray-200 text-gray-800 hover:bg-gray-300";

  return (
    <button
      className={`${baseStyles} ${primary ? primaryStyles : secondaryStyles}`}
      onClick={onClick}
    >
      {children}
    </button>
  );
};

export default Button;
```

### Global Theme Variables

```css
/* src/app/globals.css */
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";

:root {
  /* Colors */
  --color-primary-50: #eff6ff;
  --color-primary-100: #dbeafe;
  --color-primary-500: #3b82f6;
  --color-primary-700: #1d4ed8;
  --color-secondary-50: #f0f9ff;
  --color-secondary-100: #e0f2fe;
  --color-secondary-500: #0ea5e9;
  --color-secondary-700: #0369a1;

  /* Text Colors */
  --color-text-default: #171717;
  --color-text-muted: #6b7280;
  --color-text-inverted: #ffffff;

  /* Background Colors */
  --color-background-default: #ffffff;
  --color-background-alt: #f9fafb;

  /* Spacing (using Tailwind's default scale or custom) */
  --spacing-xs: 0.25rem; /* 4px */
  --spacing-sm: 0.5rem;  /* 8px */
  --spacing-md: 1rem;    /* 16px */
  --spacing-lg: 1.5rem;  /* 24px */
  --spacing-xl: 2rem;    /* 32px */

  /* Typography */
  --font-family-sans: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji";
  --font-family-mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
  --font-size-base: 1rem; /* 16px */
  --line-height-base: 1.5;

  /* Border Radius */
  --border-radius-sm: 0.25rem;
  --border-radius-md: 0.5rem;

  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

/* Dark Mode Support */
@media (prefers-color-scheme: dark) {
  :root {
    --color-text-default: #ededed;
    --color-text-muted: #a0a0a0;
    --color-text-inverted: #171717;
    --color-background-default: #0a0a0a;
    --color-background-alt: #1a1a1a;
  }
}

/* Example of extending Tailwind's theme to use CSS variables */
// tailwind.config.js (or similar)
// module.exports = {
//   theme: {
//     extend: {
//       colors: {
//         primary: {
//           50: 'var(--color-primary-50)',
//           100: 'var(--color-primary-100)',
//           500: 'var(--color-primary-500)',
//           700: 'var(--color-primary-700)',
//         },
//         background: {
//           DEFAULT: 'var(--color-background-default)',
//           alt: 'var(--color-background-alt)',
//         },
//         text: {
//           DEFAULT: 'var(--color-text-default)',
//           muted: 'var(--color-text-muted)',
//           inverted: 'var(--color-text-inverted)',
//         },
//       },
//       spacing: {
//         xs: 'var(--spacing-xs)',
//         sm: 'var(--spacing-sm)',
//         md: 'var(--spacing-md)',
//         lg: 'var(--spacing-lg)',
//         xl: 'var(--spacing-xl)',
//       },
//       borderRadius: {
//         sm: 'var(--border-radius-sm)',
//         md: 'var(--border-radius-md)',
//       },
//       boxShadow: {
//         sm: 'var(--shadow-sm)',
//         md: 'var(--shadow-md)',
//       },
//     },
//   },
// };
```