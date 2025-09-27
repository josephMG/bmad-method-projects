# Project Structure

```plaintext
nextjs-frontend/
├── .next/                  # Next.js build output (ignored)
├── node_modules/           # Project dependencies (ignored)
├── public/                 # Static assets (images, fonts)
│   ├── file.svg
│   ├── globe.svg
│   ├── next.svg
│   ├── vercel.svg
│   └── window.svg
├── src/                    # Main application source code
│   ├── app/                # Next.js App Router (pages, layouts, API routes)
│   │   ├── favicon.ico
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── components/         # Reusable UI components (e.g., buttons, cards, forms)
│   │   ├── auth/           # Authentication-related components (Login, Register, etc.)
│   │   └── common/         # Generic components
│   ├── hooks/              # Custom React hooks
│   ├── lib/                # Utility functions, helpers, API clients
│   ├── styles/             # Global styles, Tailwind config extensions
│   ├── types/              # TypeScript type definitions
│   └── utils/              # General utilities
├── tests/                  # Test files
│   ├── __mocks__/          # Mock files for testing
│   ├── unit/               # Unit tests
│   ├── integration/        # Integration tests
│   └── example.test.tsx
├── .gitignore              # Git ignore rules
├── Dockerfile.dev          # Dockerfile for development environment
├── Dockerfile.prod         # Dockerfile for production environment
├── Dockerfile.test         # Dockerfile for test environment
├── eslint.config.mjs       # ESLint configuration
├── next.config.ts          # Next.js configuration
├── package-lock.json       # npm lock file
├── package.json            # Project dependencies and scripts
├── postcss.config.mjs      # PostCSS configuration (for Tailwind)
├── README.md               # Project README
├── tsconfig.json           # TypeScript configuration
└── vitest.config.ts        # Vitest configuration
└── vitest.setup.ts         # Vitest setup file
```