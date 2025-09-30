import "@testing-library/jest-dom";
import { server } from "./tests/server";
import { vi } from "vitest";

// Polyfill AbortController for older Node.js versions or environments where it might be missing/incompatible
import { AbortController } from "node-abort-controller";
if (typeof global.AbortController === "undefined") {
  global.AbortController = AbortController;
}
if (typeof global.AbortSignal === "undefined") {
  global.AbortSignal = AbortController.AbortSignal;
}

// Mock Redux-related modules globally

vi.mock("@/store/hooks", () => ({
  useAppDispatch: vi.fn(() => vi.fn()),
}));

vi.mock("next/navigation", () => ({
  useRouter: () => ({
    push: vi.fn(),
  }),
}));

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
