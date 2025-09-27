# Frontend Tech Stack

### Technology Stack Table

| Category | Technology | Version | Purpose | Rationale |
| :--- | :--- | :--- | :--- | :--- |
| **Framework** | Next.js | 15.5.4 | React framework for frontend | Provides server-side rendering, static site generation, and a great developer experience for React applications. |
| **UI Library** | Material-UI | latest | React UI component library | Comprehensive suite of UI tools to implement Google's Material Design. (Assumed from PRD/previous stories, not explicitly in `package.json` yet) |
| **State Management** | Redux Toolkit | latest | State management for React | Official opinionated toolset for efficient Redux development. (Assumed from PRD/previous stories, not explicitly in `package.json` yet) |
| **Routing** | Next.js Router | Built-in | Client-side routing | Handles navigation within the Next.js application. |
| **Build Tool** | Next.js / Webpack | Built-in | Bundling and transpilation | Manages the build process for the Next.js application. |
| **Styling** | Tailwind CSS | 4 | Utility-first CSS framework | For rapid UI development and consistent styling. (Found in `package.json` and `postcss.config.mjs`) |
| **Testing** | Vitest, React Testing Library, Jest-DOM | 1.6.0, 16.0.0, 6.4.6 | Unit and integration testing | Fast unit testing with Vite, component testing with React Testing Library, and DOM matchers with Jest-DOM. (Found in `package.json` and `vitest.config.ts`) |
| **Component Library** | Material-UI | latest | React UI component library | Comprehensive suite of UI tools to implement Google's Material Design. (Assumed from PRD/previous stories, not explicitly in `package.json` yet) |
| **Form Handling** | (To be determined) | N/A | Managing form state and validation | Will need to be selected based on project needs. |
| **Animation** | (To be determined) | N/A | Adding animations and transitions | Will need to be selected based on project needs. |
| **Dev Tools** | ESLint | 9 | Code linting | For maintaining code quality and consistency. (Found in `package.json` and `eslint.config.mjs`) |