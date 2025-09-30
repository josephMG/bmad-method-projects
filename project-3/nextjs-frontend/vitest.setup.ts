import "@testing-library/jest-dom";
import { server } from "./tests/server";
import { vi } from "vitest";
import { AbortController } from "node-abort-controller";

global.AbortController = AbortController;

// Global MSW warning suppression
const originalConsoleWarn = console.warn;
console.warn = (...args) => {
  if (args[0] && typeof args[0] === 'string' && args[0].includes('[MSW] Warning: intercepted a request without a matching request handler:')) {
    return; // Suppress MSW warning
  }
  originalConsoleWarn(...args);
};

// Mock Redux-related modules globally

vi.mock("@/store/hooks", () => ({
  useAppDispatch: vi.fn(() => vi.fn()),
}));

vi.mock("next/navigation", () => ({
  useRouter: () => ({
    push: vi.fn(),
  }),
}));

Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(), // deprecated
    removeListener: vi.fn(), // deprecated
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
});

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
