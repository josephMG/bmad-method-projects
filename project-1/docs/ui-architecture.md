# React Calculator Frontend Architecture Document

### 1. Template and Framework Selection

The project will be built from scratch without a pre-existing starter template. The PRD explicitly defines the core technologies to be used. All tooling, bundling, and configuration will be set up manually as part of Story 1.1.

**Change Log**
| Date | Version | Description | Author |
| :--- | :--- | :--- | :--- |
| 2025-09-17 | 1.0 | Initial draft of Frontend Architecture. | Winston, Architect |

---

### 2. Frontend Tech Stack

| Category | Technology | Version | Purpose | Rationale |
| :--- | :--- | :--- | :--- | :--- |
| Framework | React | 18+ | Core application framework | Mandated by PRD. |
| UI Library | Material-UI (MUI) | 5+ | Component library for UI | Mandated by PRD for rapid, high-quality UI development. |
| State Management | React Hooks | 18+ | Local component state | Mandated by PRD. Sufficient for the app's complexity. |
| Routing | react-router-dom | 6+ | Application routing | Provides a scalable foundation for future pages. |
| Build Tool | Vite | 5+ | Fast development server and bundling | Modern, fast, and provides a great developer experience. |
| Styling | Emotion / TSS | 11+ | Styling components via MUI | Comes built-in with Material-UI. |
| Testing | Vitest, React Testing Library | Latest | Unit and Integration testing | Modern test runner that integrates seamlessly with Vite. |

---

### 3. Project Structure

```
/
├── public/
│   └── (Static assets like favicons)
├── src/
│   ├── assets/
│   │   └── (Images, fonts, etc.)
│   ├── components/
│   │   └── (Truly reusable, generic components)
│   ├── pages/
│   │   └── CalculatorPage.tsx    // The main page component
│   ├── features/
│   │   └── calculator/
│   │       ├── components/
│   │       │   ├── Display.tsx
│   │       │   ├── Keypad.tsx
│   │       │   └── History.tsx
│   │       ├── hooks/
│   │       │   └── useCalculator.ts  // Core calculator logic hook
│   ├── hooks/
│   │   └── (Global custom hooks, if any)
│   ├── styles/
│   │   └── theme.ts                // MUI theme configuration
│   ├── App.tsx                     // Main application component with routing
│   └── main.tsx                    // Application entry point
├── .gitignore
├── docker-compose.yml
├── Dockerfile
├── index.html
├── package.json
├── tsconfig.json
└── vite.config.ts
```

---

### 4. Component Standards

**Component Template**
```typescript
import React from 'react';
import { Box, Typography } from '@mui/material';

interface MyComponentProps {
  title: string;
}

const MyComponent: React.FC<MyComponentProps> = ({ title }) => {
  return (
    <Box>
      <Typography variant="h5">{title}</Typography>
    </Box>
  );
};

export default MyComponent;
```

**Naming Conventions**
*   **Files & Components:** `PascalCase` (e.g., `Keypad.tsx`, `Display.tsx`).
*   **Hooks:** `use` prefix followed by `PascalCase` (e.g., `useCalculator.ts`).
*   **Props Interfaces:** Component name followed by `Props` (e.g., `KeypadProps`).
*   **Variables & Functions:** `camelCase`.

---

### 5. State Management

**State Management Approach**
1.  **Local State:** Use `useState` for simple, component-local state.
2.  **Shared State:** Lift state up to the nearest common ancestor component.
3.  **Complex Logic:** Encapsulate all core calculator logic in the `useCalculator.ts` custom hook.

**State Management Template (Custom Hook)**
```typescript
import { useState } from 'react';

export interface CalculatorState {
  displayValue: string;
  history: string[];
}

export const useCalculator = () => {
  const [calculatorState, setCalculatorState] = useState<CalculatorState>({
    displayValue: '0',
    history: [],
  });

  const handleNumberPress = (number: string) => { /* ... */ };
  const handleOperatorPress = (operator: string) => { /* ... */ };

  return {
    ...calculatorState,
    handleNumberPress,
    handleOperatorPress,
  };
};
```

---

### 6. API Integration

Not applicable for this project. The application is fully self-contained on the client-side.

---

### 7. Routing

**Routing Approach**
The application will use `react-router-dom` to provide a scalable foundation for future pages.

**Route Configuration (`App.tsx`)**
```typescript
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import CalculatorPage from './pages/CalculatorPage';

const App: React.FC = () => {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<CalculatorPage />} />
      </Routes>
    </Router>
  );
};

export default App;
```

---

### 8. Styling Guidelines

**Styling Approach**
*   Use the `sx` prop for one-off, dynamic styles.
*   Use the `styled` utility from `@mui/material/styles` for new, reusable components.

**Global Theme (`src/styles/theme.ts`)**
```typescript
import { createTheme } from '@mui/material/styles';

export const createAppTheme = (mode: 'light' | 'dark') => {
  return createTheme({
    palette: {
      mode,
    },
  });
};
```

---

### 9. Testing Requirements

**Component Test Template**
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import MyComponent from './MyComponent';

describe('MyComponent', () => {
  it('should render correctly', () => {
    render(<MyComponent />);
    expect(screen.getByText(/MyComponent/i)).toBeInTheDocument();
  });
});
```

**Testing Best Practices**
*   **Unit Tests:** Test components and hooks in isolation.
*   **Integration Tests:** Test component interactions.
*   **Structure:** Use Arrange-Act-Assert.
*   **Queries:** Use user-facing queries (role, text, label).
*   **Coverage:** Aim for 80% code coverage.

---

### 10. Environment Configuration

No environment variables are required for the MVP. If needed in the future, they will be placed in a `.env` file and prefixed with `VITE_`.

---

### 11. Frontend Developer Standards

**Critical Coding Rules**
1.  No magic strings.
2.  Destructure props.
3.  Avoid the `any` type.
4.  Components should have a single responsibility.
5.  Follow the Rules of Hooks.
6.  Use deep imports for MUI for optimal performance.
7.  State must be treated as immutable.

**Quick Reference**
*   **Commands:** `npm run dev`, `npm run build`, `npm run test`
*   **Naming:** Components `PascalCase.tsx`, Hooks `usePascalCase.ts`
*   **Core Logic:** All calculator state and logic is managed in the `useCalculator` hook.
